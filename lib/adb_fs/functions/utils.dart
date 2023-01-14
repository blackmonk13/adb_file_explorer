part of adb_fs;

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

List<AdbFsItem> sortAdbLsOutput(
  List<AdbFsItem> items,
  String key,
  bool ascending,
) {
  return items
    ..sort(
      (a, b) {
        return ascending
            ? a.getSortKey(key).compareTo(b.getSortKey(key))
            : b.getSortKey(key).compareTo(a.getSortKey(key));
      },
    );
}
