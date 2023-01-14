part of adb_fs;

Future<bool> adbRm(
  String filePath, {
  bool recursive = false,
}) async {
  if (Platform.isWindows) {
    filePath = filePath.replaceAll('/', '\\');
  } else {
    filePath = filePath.replaceAll('\\', '/');
  }

  ProcessResult result = await Process.run(
    'adb',
    [
      'shell',
      "rm",
      recursive ? "-r" : "",
      filePath,
    ],
  );

  if (result.exitCode == 0) {
    return true;
  } else {
    return false;
  }
}
