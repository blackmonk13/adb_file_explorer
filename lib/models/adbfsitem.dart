import 'package:freezed_annotation/freezed_annotation.dart';

part 'adbfsitem.freezed.dart';
part 'adbfsitem.g.dart';

@freezed
class AdbFsItem with _$AdbFsItem {
  const AdbFsItem._();

  factory AdbFsItem({
    required String name,
    required String type,
    required String path,
    required DateTime date,
    required int size,
  }) = _AdbFsItem;

  dynamic getSortKey(String key) {
    switch (key) {
      case 'name':
        return name;
      case 'type':
        return type;
      case 'path':
        return path;
      case 'date':
        return date;
      default:
        throw ArgumentError('Invalid sort key: $key');
    }
  }

  factory AdbFsItem.fromJson(Map<String, dynamic> json) =>
      _$AdbFsItemFromJson(json);
}
