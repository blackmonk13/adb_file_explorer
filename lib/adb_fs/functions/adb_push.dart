part of adb_fs;

Future<String?> adbPush(String sourcePath, String destPath) async {
  if (Platform.isWindows) {
    sourcePath = sourcePath.replaceAll('/', '\\');
  } else {
    sourcePath = sourcePath.replaceAll('\\', '/');
  }

  ProcessResult result = await Process.run(
    'adb',
    [
      'push',
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