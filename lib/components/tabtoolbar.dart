import 'dart:io';

import 'package:android_mate/adb_fs/main.dart';
import 'package:android_mate/services/fs.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentTabProvider = StateProvider<int>(
  (ref) {
    return 0;
  },
);

class TabToolBar extends ConsumerStatefulWidget {
  const TabToolBar({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<TabToolBar> createState() => _TabToolBarState();
}

class _TabToolBarState extends ConsumerState<TabToolBar> {
  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final currentPath = ref.watch(currentPathProvider);
    final selectedItems = ref.watch(selectedFsProvider);

    return TabView(
      currentIndex: currentTab,
      closeButtonVisibility: CloseButtonVisibilityMode.never,
      tabWidthBehavior: TabWidthBehavior.sizeToContent,
      onChanged: (value) {
        ref.read(currentTabProvider.notifier).state = value;
      },
      header: DropDownButton(
        trailing: const SizedBox.shrink(),
        title: const Text('File'),
        items: [
          MenuFlyoutItem(
            text: const Text('Open Adb Shell'),
            onPressed: () async {
              await Process.run('cmd', ['/c', "start adb shell"]);
            },
          ),
          MenuFlyoutItem(
            text: const Text('Options'),
            onPressed: () {},
          ),
          MenuFlyoutItem(
            text: const Text('Help'),
            onPressed: () {},
          ),
          MenuFlyoutItem(
            text: const Text('Close'),
            onPressed: () {},
          ),
        ],
      ),
      tabs: [
        Tab(
          text: const Text("Home"),
          body: CommandBar(
            primaryItems: [
              CommandBarButton(
                onPressed: selectedItems.isEmpty
                    ? null
                    : () async {
                        if (selectedItems.isEmpty) {
                          return;
                        }
                        if (selectedItems.length == 1) {
                          final item = selectedItems.first;
                          if (item.fileType == FsType.file) {
                            await saveFolder(item: item);
                            return;
                          }
                          await saveFile(item: selectedItems.first);
                        }
                      },
                icon: Icon(
                  selectedItems.length <= 1
                      ? FluentIcons.save_as
                      : FluentIcons.save_all,
                ),
                label: Text(
                  ["Save", selectedItems.length <= 1 ? "As" : "To"].join(" "),
                ),
              ),
              CommandBarButton(
                onPressed: currentPath.path.isEmpty
                    ? null
                    : () async {
                        if (currentPath.path.isEmpty) {
                          return;
                        }
                        await saveFolderPath(folderPath: currentPath.path);
                      },
                icon: const Icon(FluentIcons.sync_folder),
                label: const Text("Save Folder"),
              ),
              CommandBarButton(
                onPressed: selectedItems.isEmpty
                    ? null
                    : () {
                        if (selectedItems.isEmpty) {
                          return;
                        }
                        showContentDialog(context);
                      },
                icon: const Icon(FluentIcons.delete),
                label: const Text("Delete"),
              ),
              const CommandBarSeparator(),
              CommandBarButton(
                onPressed: () async {
                  if (currentPath.path.isEmpty) {
                    return;
                  }
                  final files = await listFolder(currentPath.path);
                  ref.read(selectedFsProvider.notifier).addItems(files);
                },
                icon: const Icon(FluentIcons.select_all),
                label: const Text("Select All"),
              ),
              CommandBarButton(
                onPressed: selectedItems.isEmpty
                    ? null
                    : () {
                        if (selectedItems.isEmpty) {
                          return;
                        }
                        ref.read(selectedFsProvider.notifier).clear();
                        ref.read(multiselectFsProvider.notifier).state = false;
                      },
                icon: const Icon(FluentIcons.select_all),
                label: const Text(
                  "Select None",
                ),
              ),
            ],
          ),
        ),
        Tab(
          text: const Text("Share"),
          body: CommandBar(
            primaryItems: [
              CommandBarButton(
                onPressed: () {
                  if (selectedItems.isEmpty) {
                    return;
                  }
                  // context.showSnackBar(
                  //     message: selectedItems.map(
                  //   (e) {
                  //     return e.path;
                  //   },
                  // ).join('\n'));
                },
                icon: const Icon(FluentIcons.share),
                label: const Text("Share"),
              ),
              CommandBarButton(
                onPressed: selectedItems.isEmpty
                    ? null
                    : () {
                        if (selectedItems.isEmpty) {
                          return;
                        }
                        final filesOnly = selectedItems.where(
                            (element) => element.fileType == FsType.file);
                        Future.forEach(
                          filesOnly,
                          (element) async {
                            final savedPath = await saveToTemp(element);
                            if (savedPath == null) {
                              return;
                            }
                            return await sendToBluetooth(savedPath);
                          },
                        );
                        // context.showSnackBar(
                        //     message: selectedItems.map(
                        //   (e) {
                        //     return e.path;
                        //   },
                        // ).join('\n'));
                      },
                icon: const Icon(FluentIcons.send),
                label: const Text("Send To Bluetooth device"),
              ),
            ],
          ),
        ),
        Tab(
          text: const Text("View"),
          body: CommandBar(
            primaryItems: [
              CommandBarButton(
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showContentDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Delete file permanently?'),
        content: const Text(
          "If you delete this file, you won't be able to recover it. Do you want to delete it?",
        ),
        actions: [
          Button(
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context, 'User deleted file');
              // Delete file here
            },
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
    setState(() {});
  }
}
