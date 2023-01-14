part of adb_devices;

class AdbDevice {
  final String serialNumber;
  final String type;
  final String product;

  AdbDevice({
    required this.serialNumber,
    required this.type,
    required this.product,
  });
}
