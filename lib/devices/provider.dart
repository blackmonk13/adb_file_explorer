part of adb_devices;

final deviceProvider = StateProvider<AdbDevice?>(
  (ref) {
    return null;
  },
);