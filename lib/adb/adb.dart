library adb;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adb_file_explorer/models/adbdf.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as pth;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:file_picker/file_picker.dart';

import 'package:adb_file_explorer/models/adbdevice.dart';
import 'package:adb_file_explorer/models/adbfsitem.dart';

part 'devices.dart';
part 'exceptions.dart';
part 'fs.dart';
part 'utils.dart';

part 'adb.g.dart';

@riverpod
Stream<List<AdbDevice>> streamedDevices(StreamedDevicesRef ref) async* {
  while (true) {
    await Future.delayed(const Duration(seconds: 5));
    final devices = await getDevices();
    yield devices;
  }
}

@riverpod
FutureOr<List<AdbDevice>> devices(DevicesRef ref) {
  return getDevices();
}

@riverpod
FutureOr<AdbDf?> storageInfo(
  StorageInfoRef ref, {
  String? serial,
  String path = "/data",
}) {
  return getStorageInfo(
    serial: serial,
    path: path,
  );
}

@riverpod
FutureOr<List<AdbFsItem>> listDirectory(ListDirectoryRef ref, String? fullPath,
    {String? device}) {
  if (fullPath == null) {
    return [];
  }

  return listFolder(fullPath, serial: device);
}

@riverpod
class FsOps extends _$FsOps {
  @override
  Stream<String> build(
    AdbFsItem item,
    String? serial,
  ) {
    return Stream.value('');
  }

  Stream<String> pushPath(
    String localPath,
  ) {
    return adbPush(
      localPath,
      item.path,
      serial: serial,
    );
  }

  Stream<String> pullPath(
    String localPath,
  ) {
    return adbPull(
      item.path,
      localPath,
      serial: serial,
    );
  }

  Future<String> openFile(String filePath) async {
    final result = await OpenFilex.open(filePath);

    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }

    return filePath;
  }

  Future<void> deleteFile() async {
    state = const AsyncLoading();
    try {
      await for (final value in adbDelete(item.path, serial: serial)) {
        state = AsyncValue.data(value);
      }
      ref.invalidate(listDirectoryProvider(
        pth.dirname(item.path),
        device: serial,
      ));
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> deleteFolder() async {
    state = const AsyncLoading();
    try {
      await for (final value
          in adbDelete(item.path, serial: serial, recursive: true)) {
        state = AsyncValue.data(value);
      }
      ref.invalidate(listDirectoryProvider(
        pth.dirname(item.path),
        device: serial,
      ));
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> saveAs() async {
    state = const AsyncLoading();
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: pth.basename(item.path),
      );

      if (outputFile == null) {
        // User canceled the picker
        state = const AsyncValue.data('');
        return;
      }

      await for (final value in pullPath(outputFile)) {
        state = AsyncValue.data(value);
      }
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> saveTo() async {
    state = const AsyncLoading();
    try {
      final downloadsDir = await getDownloadsDirectory();
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        initialDirectory: downloadsDir?.path,
      );

      if (selectedDirectory == null) {
        // User canceled the picker
        state = const AsyncValue.data('');
        return;
      }

      await for (final value in pullPath(selectedDirectory)) {
        state = AsyncValue.data(value);
      }
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> viewFile() async {
    state = const AsyncLoading();
    try {
      if (serial == null) {
        throw Exception("Device not found.");
      }

      final itemPath = item.path;
      final itemDirname =
          pth.normalize(pth.dirname(itemPath).replaceFirst('/', ''));
      final tempDir = await getTemporaryDirectory();
      final saveDirPath = pth.join(
        tempDir.path,
        'afe',
        serial,
        itemDirname,
      );
      final savedFilePath = pth.join(saveDirPath, pth.basename(item.path));
      final savedFile = File(savedFilePath);

      if (await savedFile.exists()) {
        state = await AsyncValue.guard(() {
          return openFile(savedFilePath);
        });
        return;
      }

      final saveDir = Directory(saveDirPath);
      await saveDir.create(recursive: true);

      await for (final value in pullPath(savedFilePath)) {
        state = AsyncValue.data(value);
      }

      if (await savedFile.exists()) {
        state = await AsyncValue.guard(() {
          return openFile(savedFilePath);
        });
      }
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Stream<String> uploadPath(String localPath) async* {
    final isFile = await FileSystemEntity.isFile(localPath);
    final isDir = await FileSystemEntity.isDirectory(localPath);

    if (isFile && !await File(localPath).exists()) {
      throw Exception("File does not exist");
    }

    if (isDir && !await Directory(localPath).exists()) {
      throw Exception("Folder does not exist");
    }

    await for (final value in pushPath(localPath)) {
      yield value;
    }
  }

  Future<bool> pushPaths(List<String> localPaths) async {
    state = const AsyncLoading();
    try {
      await Future.wait(
        localPaths.map(
          (localPath) async {
            await for (final value in uploadPath(localPath)) {
              state = AsyncValue.data(value);
            }
          },
        ),
      );

      ref.invalidate(listDirectoryProvider(
        pth.dirname(item.path),
        device: serial,
      ));
      return true;
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
    return false;
  }

  Future<void> pickAndPushFiles() async {
    state = const AsyncLoading();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result == null) {
        // User canceled the picker
        state = const AsyncValue.data('');
        return;
      }

      final localPaths =
          result.paths.where((e) => e != null).map((e) => e!).toList();

      await Future.wait(
        localPaths.map((localPath) async {
          await for (final value in uploadPath(localPath)) {
            state = AsyncValue.data(value);
          }
        }),
      );

      ref.invalidate(listDirectoryProvider(
        pth.dirname(item.path),
        device: serial,
      ));
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> pushFolder() async {
    state = const AsyncLoading();
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // User canceled the picker
        state = const AsyncValue.data('');
        return;
      }

      await for (final value in pushPath(selectedDirectory)) {
        state = AsyncValue.data(value);
      }
      ref.invalidate(listDirectoryProvider(
        pth.dirname(item.path),
        device: serial,
      ));
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}
