part of "adb.dart";

const _interval = Duration(milliseconds: 100);

Future<ProcessResult> runAdb({
  String? serial,
  List<String> args = const [],
}) async {
  await ensureServerRunning();
  ProcessResult result = await Process.run(
    'adb',
    [
      if (serial != null) ...[
        '-s',
        serial,
      ],
      ...args
    ],
  );

  return result;
}

Future<Process> streamedAdb({
  String? serial,
  List<String> args = const [],
}) async {
  await ensureServerRunning();
  Process result = await Process.start(
    'adb',
    [
      if (serial != null) ...[
        '-s',
        serial,
      ],
      ...args
    ],
  );

  return result;
}

Future<void> ensureServerRunning() async {
  try {
    await Process.run('adb', []);
  } on ProcessException catch (err) {
    throw AdbExecutableNotFound(message: err.message);
  }
  while (true) {
    final result = await Process.run(
      'adb',
      ['start-server'],
      runInShell: true,
    );
    if (result.stderr.contains(AdbDaemonNotRunning.trigger)) {
      await Future<void>.delayed(_interval);
    } else {
      break;
    }
  }
}

double bytesToKilobytes(int bytes) {
  return bytes / 1024;
}

double bytesToMegabytes(int bytes) {
  return bytesToKilobytes(bytes) / 1024;
}

String escapeSpaces(String s) {
  StringBuffer sb = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (s[i] == ' ') {
      sb.write('\\');
    }
    sb.write(s[i]);
  }
  return sb.toString();
}

String convertToLargerUnit(int bytes) {
  int kilobytes = bytes ~/ 1024;

  if (kilobytes < 1024) {
    return "${kilobytes.toStringAsFixed(2)} KB";
  } else if (kilobytes < 1024 * 1024) {
    double megabytes = kilobytes / 1024;
    return "${megabytes.toStringAsFixed(2)} MB";
  } else {
    double gigabytes = kilobytes / (1024 * 1024);
    return "${gigabytes.toStringAsFixed(2)} GB";
  }
}

String formatFileSize(String? fileSize) {
  if (fileSize == null || fileSize.isEmpty) return "Unknown size";

  double? sizeInBytes = double.tryParse(fileSize.split(' ')[0]);

  if (sizeInBytes == null) {
    return "Invalid size";
  }

  const units = ["bytes", "KB", "MB", "GB", "TB", "PB"];
  int unitIndex = 0;

  while (sizeInBytes! >= 1024 && unitIndex < units.length - 1) {
    sizeInBytes /= 1024;
    unitIndex++;
  }

  return "${sizeInBytes.toStringAsFixed(2)} ${units[unitIndex]}";
}

enum LsSortKey { name, type, filePath, date }

String getLinkPath(String filePath) {
  List<String> fields = filePath.split(' -> ');
  debugPrint("Fields ${fields.length}");
  if (fields.isEmpty) {
    return filePath;
  }

  if (fields.length < 2) {
    return filePath;
  }

  return fields.first;
}

String pathType(String type, String ftype) {
  switch (ftype) {
    case "directory":
      return 'd';
    case "file":
      return '-';
    default:
      return type;
  }
}
