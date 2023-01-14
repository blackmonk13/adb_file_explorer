import 'package:android_mate/adb_fs/main.dart';
import 'package:android_mate/devices/main.dart';
import 'package:android_mate/utils/common.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final treeExpandedProvider =
    StateProvider.autoDispose.family<bool, dynamic>((ref, item) {
  return false;
});

class FsTree extends ConsumerStatefulWidget {
  const FsTree({Key? key}) : super(key: key);

  @override
  ConsumerState<FsTree> createState() => _FsTreeState();
}

class _FsTreeState extends ConsumerState<FsTree> {
  @override
  Widget build(BuildContext context) {
    return TreeView(
      shrinkWrap: true,
      items: treeItems,
      onItemInvoked: (item, reason) async {
        debugPrint('onItemInvoked: ${item.value.runtimeType}');
      },
      onSelectionChanged: (selectedItems) async => debugPrint(
          'onSelectionChanged: ${selectedItems.map((i) => i.value)}'),
      onSecondaryTap: (item, details) async {
        debugPrint('onSecondaryTap $item at ${details.globalPosition}');
      },
    );
  }

  List<TreeViewItem> get treeItems {
    return [
      TreeViewItem(
        content: Text(
          "This PC",
          style: context.textTheme.bodyStrong?.copyWith(
            color: context.themeData.activeColor,
          ),
          overflow: TextOverflow.fade,
        ),
        value: "thispc",
        leading: const Icon(FluentIcons.this_p_c),
        lazy: true,
        children: [],
        onExpandToggle: (item, getsExpanded) async {
          // If it's already populated, return.
          if (item.children.isNotEmpty) return;
          final devices = await getDevices();
          item.children.addAll(
            devices.map(
              (devc) {
                return TreeViewItem(
                  value: devc,
                  lazy: true,
                  children: [],
                  leading: const Icon(FluentIcons.cell_phone),
                  content: Text(
                    devc.product,
                    style: context.textTheme.bodyStrong?.copyWith(
                      color: context.themeData.activeColor,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                  onInvoked: (item, reason) async {
                    ref.read(deviceProvider.notifier).state =
                        item.value as AdbDevice;
                    ref.read(currentPathProvider.notifier).state = AdbFsItem(
                      name: "root",
                      fileType: FsType.folder,
                      path: "/",
                      date: DateTime.now(),
                      size: 0,
                    );
                    // goToFs(
                    //   ref,
                    //   fsPath: "/",
                    // );
                  },
                  onExpandToggle: (item, getsExpanded) async {
                    if (item.children.isNotEmpty) return;
                    await onExpandFolder(item, getsExpanded, "/");
                  },
                );
              },
            ),
          );
        },
      ),
    ];
  }

  Future<void> onExpandFs(
    TreeViewItem item,
    bool getsExpanded,
    String fpath,
  ) async {
    if (item.children.isNotEmpty) return;
    final itemData = item.value as AdbFsItem;
    if (itemData.fileType != FsType.folder) {
      return;
    }
    await onExpandFolder(item, getsExpanded, fpath);
  }

  Future<void> onExpandFolder(
    TreeViewItem item,
    bool getsExpanded,
    String fpath,
  ) async {
    final files = await listFolder(fpath);
    item.children.addAll(
      files.where(
        (element) {
          return element.fileType == FsType.folder;
        },
      ).map(
        (ftm) {
          return TreeViewItem(
            value: ftm,
            lazy: true,
            children: [],
            leading: const Icon(FluentIcons.folder),
            content: Text(
              ftm.name,
              style: context.textTheme.bodyStrong?.copyWith(
                color: context.themeData.activeColor,
              ),
              overflow: TextOverflow.fade,
            ),
            onInvoked: (item, reason) async {
              ref.read(currentPathProvider.notifier).state = ftm;
              ref.read(selectedFsProvider.notifier).addSingle(ftm);
              // goToFs(
              //   ref,
              //   fsPath: ftm.path,
              // );
            },
            onExpandToggle: (item, getsExpanded) async {
              await onExpandFs(item, getsExpanded, ftm.path);
            },
          );
        },
      ),
    );
  }
}
