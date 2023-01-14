import 'dart:io';

import 'package:android_mate/services/fs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:path_provider/path_provider.dart';

final splitAreasProvider = StateProvider<List<double?>>(
  (ref) {
    return [0.0, 0.0];
  },
);

Future<String?> getAppTempDir() async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  final ourtemp = createDirectory("fluadb", tempPath);
  return ourtemp;
}

final tempPathProvider = FutureProvider<String>((ref) async {
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  return tempPath;
});

final tempProvider = Provider<String>((ref) {
  final tdir = ref.watch(tempPathProvider);
  String tpath = "";
  tdir.when(
    data: (data) {
      final ourtemp = createDirectory("fluadb", data);
      if (ourtemp == null) {
        tpath = data;
      } else {
        tpath = ourtemp;
      }
    },
    error: (error, stackTrace) {},
    loading: () {},
  );
  return tpath;
});

final loadStateProvider = StateProvider<bool>(
  (ref) {
    return false;
  },
);

final itemCountProvider = StateProvider<int?>(
  (ref) {
    return null;
  },
);
