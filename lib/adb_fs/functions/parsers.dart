part of adb_fs;

List<AdbFsItem> parseAdbLsOutput(String adbOutput) {
  // Split the output into lines
  List<String> lines = adbOutput.split('\n');

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

    // Number of items (1 if its a file or link)
    int items = int.tryParse(fields[1]) ?? 1;

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
        fileType: getFsType(type),
        path: name,
        size: size,
        date: dateTime,
        items: items,
      ),
    );
  }

  return result;
}

FsType getFsType(String type) {
  switch (type) {
    case "d":
      return FsType.folder;
    case "-":
      return FsType.file;
    case "l":
      return FsType.link;
    default:
      return FsType.unknown;
  }
}

String getLinkPath(String filePath) {
  List<String> fields = filePath.split(' -> ');
  if (fields.isEmpty) {
    return filePath;
  }

  if (fields.length < 2) {
    return filePath;
  }

  return fields.last;
}

FsType pathType(String type, String ftype) {
  switch (ftype) {
    case "directory":
      return FsType.folder;
    case "file":
      return FsType.file;
    default:
      return FsType.unknown;
  }
}

// TODO: better property resolution
Future<AdbFsItem> fsItemFromPath(String fullPath) async {
  if (fullPath == "/") {
    return AdbFsItem(
      name: "root",
      fileType: FsType.folder,
      path: "/",
      date: DateTime.now(),
      size: 0,
    );
  }
  String name = pth.basename(fullPath);
  FsType fileType = await getStatFsType(fullPath);
  return AdbFsItem(
    name: name,
    fileType: fileType,
    path: fullPath,
    date: DateTime.now(),
    size: 0,
  );
}
