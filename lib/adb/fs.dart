part of 'adb.dart';

Future<String> getStatFileType(
  String path, {
  String? serial,
}) async {
  // Run the "adb shell stat -L -c %F" command
  final result = await streamedAdb(
    serial: serial,
    args: [
      'shell',
      'stat',
      '-L',
      '-c',
      '%F',
      path,
    ],
  );

  // Read the output from the command
  String output = await result.stdout.transform(utf8.decoder).join();

  // Parse the output to determine the file type
  if (output.trim() == 'symbolic link') {
    return 'symlink';
  } else if (output.trim() == 'regular file') {
    return 'file';
  } else if (output.trim() == 'directory') {
    return 'directory';
  } else {
    return 'unknown';
  }
}

Future<List<AdbFsItem>> listFolder(
  String fullPath, {
  String? serial,
}) async {
  // Create a Process object to run the command
  final process = await runAdb(
    serial: serial,
    args: [
      "shell",
      "ls",
      "-l",
      escapeSpaces(fullPath),
    ],
  );

  String stdout = process.stdout.toString();
  String stderr = process.stderr.toString();
  if (AdbShellLsPermissionDenied.trigger.hasMatch(stderr.trim())) {
    throw const AdbShellLsPermissionDenied(
      message: "You are not authorised to view the contents of this folder",
    );
  }

  // print(stderr);
  // final Directory? downloadsDir = await getDownloadsDirectory();
  // final Directory tempDir = await getTemporaryDirectory();
  // final Directory appCacheDir = await getApplicationCacheDirectory();

  // print("Downloads: ${downloadsDir?.path}");
  // print("Temp: ${tempDir.path}");
  // print("AppCache: ${appCacheDir.path}");

  final result = parseAdbLsOutput(stdout);
  final futures = result.map(
    (fsItem) async {
      if (fullPath.toLowerCase() == fsItem.path.toLowerCase()) {
        return fsItem;
      }
      final sanitizedPath = pth
          .join(
            fullPath.trimRight().trimLeft(),
            fsItem.path.trimRight().trimLeft(),
          )
          .replaceAll('\\', '/')
          .trimRight()
          .trimLeft();

      if (fsItem.type == 'l') {
        final linkPath = getLinkPath(sanitizedPath);
        final actualPath = await getStatFileType(
          linkPath,
          serial: serial,
        );
        return fsItem.copyWith(
          type: pathType(linkPath, actualPath),
          path: linkPath,
        );
      }

      return fsItem.copyWith(
        path: sanitizedPath,
      );
    },
  ).toList();

  return await Future.wait(futures);
}

List<AdbFsItem> parseAdbLsOutput(String adbOutput) {
  // Split the output into lines
  List<String> lines =
      adbOutput.split('\n').where((e) => e.isNotEmpty).toList();

  // if (lines.length == 1) {
  //   final parts = lines.first.split(':');
  //   print(parts.length);
  // }

  // print(lines.length);

  // Initialize the result list
  List<AdbFsItem> result = [];

  // Iterate through the lines
  for (String line in lines) {
    // Ignore empty lines
    if (line.trim().isEmpty) {
      continue;
    }

    if (line.contains("?")) {
      continue;
    }

    // Split the line into fields
    List<String> fields = line.split(RegExp(r'\s+'));

    if (fields.length < 7) {
      continue;
    }

    // Extract the file type (first field)
    String type = fields[0][0];

    // Extract the size (fourth field)
    int size = int.tryParse(fields[4]) ?? 0;

    // Extract the date and time (fifth and sixth fields)
    String date = fields[5];
    String time = fields[6];

    // Extract the name (seventh field and beyond)
    String name = fields.sublist(7).join(' ');

    DateTime dateTime = DateTime.tryParse('$date $time') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    // Add the data to the result list
    result.add(
      AdbFsItem(
        name: name.split('/').last,
        type: type,
        path: name,
        size: size,
        date: dateTime,
      ),
    );
  }

  return result;
}

List<AdbFsItem> sortAdbLsOutput(
  List<AdbFsItem> items,
  String key,
  bool ascending,
) {
  return items
    ..sort((a, b) => ascending
        ? a.getSortKey(key).compareTo(b.getSortKey(key))
        : b.getSortKey(key).compareTo(a.getSortKey(key)));
}

Future<AdbDf?> getStorageInfo({
  String? serial,
  String path = '/data',
}) async {
  ProcessResult result = await runAdb(
    serial: serial,
    args: ['shell', 'df', '-a', path],
  );

  if (result.exitCode == 0) {
    // The command was successful, parse the output to get the storage info
    String output = result.stdout as String;

    final parsed = parseAdbShellDfOutput(output);

    // print('Total storage: ${formatFileSize(parsed.total.toString())}');
    // print('Used storage: ${parsed.used}');
    // print('Free storage: ${parsed.free}');
    return parsed;
  } else {
    // There was an error running the command
    // print('Error getting storage info: ${result.stderr}');
    return null;
  }
}

// Parses the output of the 'adb shell df' command and returns a map
// with the following keys:
// - total: total amount of storage
// - used: total amount of used storage
// - free: total amount of free storage
AdbDf parseAdbShellDfOutput(String output) {
  // Split the output into lines
  List<String> lines = output.split('\n');

  // Initialize the total, used, and free values to 0
  int total = 0;
  int used = 0;
  int free = 0;

  // Iterate through each line
  for (String line in lines) {
    // Split the line into fields
    List<String> fields = line.split(RegExp(r'\s+'));

    // Skip the line if it doesn't have enough fields
    if (fields.length < 6) {
      continue;
    }

    // Parse the total, used, and free values from the fields
    int lineTotal = int.tryParse(fields[1]) ?? 0;
    int lineUsed = int.tryParse(fields[2]) ?? 0;
    int lineFree = int.tryParse(fields[3]) ?? 0;

    // Add the values for this line to the total, used, and free values
    total += lineTotal;
    used += lineUsed;
    free += lineFree;
  }

  // Return the map with the total, used, and free values
  return AdbDf(
    total: total,
    used: used,
    free: free,
  );
}

Stream<String> adbPull(
  String remotePath,
  String localPath, {
  String? serial,
}) async* {
  final process = await streamedAdb(
    serial: serial,
    args: [
      'pull',
      remotePath,
      localPath,
    ],
  );

  final stdoutStream = process.stdout.transform(utf8.decoder);
  final stderrStream = process.stderr.transform(utf8.decoder);

  // Combine stdout and stderr streams
  final combinedStream = StreamGroup.merge([stdoutStream, stderrStream]);

  await for (final line in combinedStream) {
    // Process each line from the combined stream
    if (line.startsWith('adb: error:')) {
      if (AdbPullPermissionDenied.trigger.hasMatch(line)) {
        throw AdbPullPermissionDenied(
          message: line,
        );
      } else if (AdbPullFileOrDirectoryNotFound.trigger.hasMatch(line)) {
        throw AdbPullFileOrDirectoryNotFound(
          message: line,
        );
      } else {
        // Handle other error cases as needed
        throw Exception('adb pull failed: $line');
      }
    } else {
      // Emit progress updates (excluding error messages)
      yield line;
    }
  }
}

Stream<String> adbPush(
  String localPath,
  String remotePath, {
  String? serial,
}) async* {
  final process = await streamedAdb(
    serial: serial,
    args: [
      'push',
      localPath,
      remotePath,
    ],
  );

  final stdoutStream = process.stdout.transform(utf8.decoder);
  final stderrStream = process.stderr.transform(utf8.decoder);

  // Combine stdout and stderr streams
  final combinedStream = StreamGroup.merge([stdoutStream, stderrStream]);

  await for (final line in combinedStream) {
    // Process each line from the combined stream
    if (line.startsWith('adb: error:')) {
      if (AdbPushReadOnlyFs.trigger.hasMatch(line)) {
        throw AdbPushReadOnlyFs(
          message: line,
        );
      } else if (AdbPushOperationNotPermitted.trigger.hasMatch(line)) {
        throw AdbPushOperationNotPermitted(
          message: line,
        );
      } else if (AdbPushNoSuchFileOrDirectory.trigger.hasMatch(line)) {
        throw AdbPushNoSuchFileOrDirectory(
          message: line,
        );
      } else {
        // Handle other error cases as needed
        throw Exception('adb push failed: $line');
      }
    } else {
      // Emit progress updates (excluding error messages)
      yield line;
    }
  }
}

Stream<String> adbDelete(
  String remotePath, {
  String? serial,
  bool recursive = false,
}) async* {
  final process = await streamedAdb(
    serial: serial,
    args: [
      'shell',
      'rm',
      if (recursive) '-rf',
      remotePath,
    ],
  );

  final stdoutStream = process.stdout.transform(utf8.decoder);
  final stderrStream = process.stderr.transform(utf8.decoder);

  // Combine stdout and stderr streams
  final combinedStream = StreamGroup.merge([stdoutStream, stderrStream]);

  await for (final line in combinedStream) {
    // Process each line from the combined stream
    if (line.startsWith('adb: error:')) {
      // Handle other error cases as needed
      throw Exception('Delete failed: $line');
    } else {
      // Emit progress updates (excluding error messages)
      yield line;
    }
  }
}
