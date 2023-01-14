part of adb_fs;

Future<List<AdbFsItem>> listFolder(String fullPath,
    {bool hidden = true}) async {
  // Create a Process object to run the command
  final process = await Process.run(
    'adb',
    [
      "shell",
      "ls",
      hidden ? "-Al" : "-l",
      escapeSpaces(fullPath),
    ],
  );
  String stdout = process.stdout.toString();
  final result = parseAdbLsOutput(stdout);
  final cresult = result.map(
    (fsIt) async {
      if (fullPath.toLowerCase() == fsIt.path.toLowerCase()) {
        return fsIt;
      }
      final npath = pth
          .join(
            fullPath.trimRight().trimLeft(),
            fsIt.path.trimRight().trimLeft(),
          )
          .replaceAll('\\', '/')
          .trimRight()
          .trimLeft();
      if (fsIt.fileType == FsType.link) {
        final lnkPath = getLinkPath(npath);
        final pTo = await getStatFileType(lnkPath);
        return fsIt.copyWith(
          linkType: pTo,
          // type: pathType(fsIt.type, pTo),
          path: lnkPath,
        );
      }
      return fsIt.copyWith(
        path: npath,
      );
    },
  ).toList();
  return await Future.wait(cresult);
}

Future<FsLinkType> getStatFileType(String path) async {
  // Run the "adb shell stat -L -c %F" command
  Process process =
      await Process.start('adb', ['shell', 'stat', '-L', '-c', '%F', path]);

  // Read the output from the command
  String output = await process.stdout.transform(utf8.decoder).join();

  // Parse the output to determine the file type
  if (output.trim() == 'symbolic link') {
    return FsLinkType.unknown;
  } else if (output.trim() == 'regular file') {
    return FsLinkType.file;
  } else if (output.trim() == 'directory') {
    return FsLinkType.folder;
  } else {
    return FsLinkType.unknown;
  }
}

// TODO: Use one enum
Future<FsType> getStatFsType(String path) async {
  // Run the "adb shell stat -L -c %F" command
  Process process =
      await Process.start('adb', ['shell', 'stat', '-L', '-c', '%F', path]);

  // Read the output from the command
  String output = await process.stdout.transform(utf8.decoder).join();

  // Parse the output to determine the file type
  if (output.trim() == 'symbolic link') {
    return FsType.unknown;
  } else if (output.trim() == 'regular file') {
    return FsType.file;
  } else if (output.trim() == 'directory') {
    return FsType.folder;
  } else {
    return FsType.unknown;
  }
}
