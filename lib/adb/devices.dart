part of 'adb.dart';

Future<List<AdbDevice>> getDevices() async {
  final process = await runAdb(
    args: [
      "devices",
      "-l",
    ],
  );
  String stdout = process.stdout.toString();
  final result = parseAdbDevicesOutput(stdout);
  return result;
}

List<AdbDevice> parseAdbDevicesOutput(String output) {
  // Split the output into lines
  List<String> lines = output.split('\n');

  // Initialize the result list
  List<AdbDevice> devices = [];

  // Iterate through the lines
  for (String line in lines) {
    // Ignore empty lines and the first line ("List of devices attached")
    if (line.trim().isEmpty || line.startsWith('List of devices attached')) {
      continue;
    }

    // Split the line into fields
    List<String> fields = line.split(RegExp(r'\s+'));

    // Extract the serial number, state, and type
    String serialNumber = fields[0];
    String state = fields[1];

    if (fields.length < 2) {
      devices.add(
        AdbDevice(
          serialNumber: serialNumber,
          type: state,
          product: '',
        ),
      );
      continue;
    }

    String product = procMeta(fields[2]);

    // Add the data to the result list
    devices.add(
      AdbDevice(
        serialNumber: serialNumber,
        type: state,
        product: product,
      ),
    );
  }

  // Return the list of devices
  return devices;
}

String procMeta(String? field) {
  if (field == null) {
    return '';
  }

  if (field.isEmpty) {
    return field;
  }

  final fv = field.split(':');

  if (fv.length < 2) {
    return field;
  }
  return fv.last;
}
