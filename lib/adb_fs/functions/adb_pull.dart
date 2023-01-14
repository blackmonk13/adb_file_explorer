part of adb_fs;

Future<String?> adbPull(String sourcePath, String destPath) async {
  if (Platform.isWindows) {
    destPath = destPath.replaceAll('/', '\\');
  } else {
    destPath = destPath.replaceAll('\\', '/');
  }

  ProcessResult result = await Process.run(
    'adb',
    [
      'pull',
      sourcePath,
      destPath,
    ],
  );

  if (result.exitCode == 0) {
    return destPath;
  } else {
    return null;
  }
}