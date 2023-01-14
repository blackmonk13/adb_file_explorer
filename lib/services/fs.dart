import 'dart:io';

import 'package:android_mate/adb_fs/main.dart';
import 'package:android_mate/providers/common.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as pth;


Future<void> sendToBluetooth(String filePath) async {
  filePath = filePath.trimLeft().trimRight();
  await Process.run('fsquirt', ['-send', filePath]);
}

Future<void> openFile(String filePath) async {
  filePath = filePath.trimLeft().trimRight();
  if (Platform.isWindows) {
    // On Windows, use the start command
    await Process.run('cmd', ['/c', filePath]);
  } else if (Platform.isMacOS) {
    // On macOS, use the open command
    await Process.run('open', [filePath]);
  } else if (Platform.isLinux) {
    // On Linux, use the open command
    await Process.run('open', [filePath]);
  }
}

String? createDirectory(String name, String path) {
  String fullPath = pth.join(path, name);
  if (Platform.isWindows) {
    fullPath = fullPath.replaceAll('/', '\\');
  } else {
    fullPath = fullPath.replaceAll('\\', '/');
  }
  // Check if the directory already exists
  if (Directory(fullPath).existsSync()) {
    // Return the full path to the existing directory
    return fullPath;
  }
  try {
    // Create a new directory with the given name and path
    Directory(fullPath).create();
    // Return the full path to the new directory
    return fullPath;
  } catch (e) {
    // Return null if there was an error creating the directory
    return null;
  }
}

final GlobalKey<NavigatorState> fsNavKey = GlobalKey<NavigatorState>();

void goToFs(WidgetRef ref, {required String fsPath}) {
  ref.read(multiselectFsProvider.notifier).state = false;
  fsNavKey.currentState?.pushNamed(
    '/files',
    arguments: fsPath,
  );
}

void popFs(WidgetRef ref) {
  ref.read(selectedFsProvider.notifier).clear();
  ref.read(multiselectFsProvider.notifier).state = false;
  fsNavKey.currentState?.maybePop();
}

Future<String?> saveToTemp(AdbFsItem item) async {
  final tempPath = await getAppTempDir();
  if (tempPath == null) {
    return null;
  }

  String dirname = pth.dirname(item.path);
  final drsub = dirname.substring(1);
  final drlist = drsub.split('/').toList();
  String newDir = tempPath;
  for (String element in drlist) {
    final apath = createDirectory(element, newDir);
    if (apath == null) {
      continue;
    }
    newDir = apath;
  }

  String? outfile = await adbPull(item.path, newDir);

  if (outfile == null) {
    return null;
  }

  if (pth.basename(outfile) != item.name) {
    outfile = pth.join(outfile, item.name);
  }
  return outfile;
}

Future<void> viewFile({
  required WidgetRef ref,
  required AdbFsItem item,
}) async {
  final outfile = await saveToTemp(item);

  if (outfile == null) {
    return;
  }

  print(outfile);
  try {
    openFile(outfile);
  } catch (e) {
    await saveFile(item: item);
  }
}

Future<String?> saveFile({
  required AdbFsItem item,
}) async {
  String? outputFile = await FilePicker.platform.saveFile(
    dialogTitle: 'Please select an output file:',
    fileName: item.name,
  );

  if (outputFile == null) {
    // User canceled the picker
    return null;
  }
  final outFile = await adbPull(item.path, outputFile);

  return outFile;
}

Future<String?> saveFolder({
  required AdbFsItem item,
}) async {
  String? outputFile = await FilePicker.platform.getDirectoryPath();
  if (outputFile == null) {
    // User canceled the picker
    return null;
  }
  final outFile = await adbPull(item.path, outputFile);

  return outFile;
}

Future<String?> saveFolderPath({
  required String folderPath,
}) async {
  String? outputFile = await FilePicker.platform.getDirectoryPath();
  if (outputFile == null) {
    // User canceled the picker
    return null;
  }
  final outFile = await adbPull(folderPath, outputFile);

  return outFile;
}
