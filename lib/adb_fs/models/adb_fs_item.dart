part of adb_fs;

enum FsType {
  file,
  folder,
  link,
  unknown,
}

enum FsLinkType {
  file,
  folder,
  unknown,
}

class AdbFsItem {
  final String name;
  final FsType fileType;
  final String path;
  final DateTime date;
  final int size;
  final int items;
  final FsLinkType linkType;

  AdbFsItem({
    required this.name,
    required this.fileType,
    required this.path,
    required this.date,
    required this.size,
    this.items = 1,
    this.linkType = FsLinkType.unknown,
  });

  dynamic getSortKey(String key) {
    switch (key) {
      case 'name':
        return name;
      case 'type':
        return fileType;
      case 'path':
        return path;
      case 'date':
        return date;
      default:
        throw ArgumentError('Invalid sort key: $key');
    }
  }

  AdbFsItem copyWith({
    String? path,
    FsType? fileType,
    int? items,
    FsLinkType? linkType,
  }) {
    return AdbFsItem(
      name: name,
      fileType: fileType ?? this.fileType,
      path: path ?? this.path,
      date: date,
      size: size,
      items: items ?? this.items,
      linkType: linkType ?? this.linkType,
    );
  }

  AdbFsItem.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        fileType = json["type"],
        path = json["path"],
        date = DateTime.parse(json["date"]),
        size = int.tryParse(json["size"]) ?? 0,
        items = int.tryParse(json["items"]) ?? 1,
        linkType = json["linkType"];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': fileType,
      'path': path,
      'date': date.toIso8601String(),
      'size': size,
      'items': items,
    };
  }
}
