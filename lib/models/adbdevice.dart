
import 'package:freezed_annotation/freezed_annotation.dart';

part 'adbdevice.freezed.dart';
part 'adbdevice.g.dart';

@freezed
class AdbDevice with _$AdbDevice {
  factory AdbDevice({
    required String serialNumber,
    required String type,
    required String product,
  }) = _AdbDevice;
	
  factory AdbDevice.fromJson(Map<String, dynamic> json) =>
			_$AdbDeviceFromJson(json);
}
