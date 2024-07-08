
import 'package:freezed_annotation/freezed_annotation.dart';

part 'adbdf.freezed.dart';
part 'adbdf.g.dart';

@freezed
class AdbDf with _$AdbDf {
  factory AdbDf({
    required int total,
    required int used,
    required int free,
  }) = _AdbDf;
	
  factory AdbDf.fromJson(Map<String, dynamic> json) =>
			_$AdbDfFromJson(json);
}
