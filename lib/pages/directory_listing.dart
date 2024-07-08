import 'package:adb_file_explorer/adb/adb.dart';
import 'package:adb_file_explorer/models/adbfsitem.dart';
import 'package:adb_file_explorer/utils/extensions.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:adb_file_explorer/components/fs_list_tile.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class DirectoryListing extends HookConsumerWidget {
  const DirectoryListing({
    super.key,
    this.serial,
    this.directory,
  });
  final String? directory;
  final String? serial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextController = FlyoutController();
    final contextAttachKey = GlobalKey();
    final decodedDirectory =
        directory == null ? "/" : Uri.decodeComponent(directory!);
    final asyncListing = ref.watch(listDirectoryProvider(
      decodedDirectory,
      device: serial,
    ));
    final selectedIndex = useState<int?>(null);

    return GestureDetector(
      onSecondaryTapUp: (d) async {
        if (!context.mounted) {
          return;
        }
        // This calculates the position of the flyout according to the parent navigator
        final targetContext = contextAttachKey.currentContext;
        if (targetContext == null) return;
        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          d.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );
    
        final parentPath = p.dirname(decodedDirectory);
        final parentList = await ref.read(
          listDirectoryProvider(parentPath, device: serial).future,
        );
    
        final itemfilter =
            parentList.where((e) => e.path == decodedDirectory).toList();
    
        if (itemfilter.isEmpty) {
          return;
        }
    
        final item = itemfilter.first;
    
        contextController.showFlyout(
          barrierColor: Colors.black.withOpacity(0.1),
          position: position,
          builder: (context) {
            return DirectoryFlyout(
              item: item,
              serial: serial,
            );
          },
        );
      },
      child: FlyoutTarget(
        key: contextAttachKey,
        controller: contextController,
        child: DropRegion(
          formats: Formats.standardFormats,
          hitTestBehavior: HitTestBehavior.translucent,
          onDropOver: (DropOverEvent event) {
            // You can inspect local data here, as well as formats of each item.
            // However on certain platforms (mobile / web) the actual data is
            // only available when the drop is accepted (onPerformDrop).
            final item = event.session.items.first;
            if (item.localData is Map) {
              // This is a drag within the app and has custom local data set.
            }
            if (item.canProvide(Formats.plainText)) {
              // this item contains plain text.
            }
            // This drop region only supports copy operation.
            if (event.session.allowedOperations.contains(DropOperation.copy)) {
              return DropOperation.copy;
            } else {
              return DropOperation.none;
            }
          },
          onPerformDrop: (PerformDropEvent event) async {
            if (!context.mounted) {
              return;
            }
            final parentPath = p.dirname(decodedDirectory);
            final parentList = await ref.read(
              listDirectoryProvider(parentPath, device: serial).future,
            );
        
            final itemfilter =
                parentList.where((e) => e.path == decodedDirectory).toList();
        
            if (itemfilter.isEmpty) {
              return;
            }
        
            final adbItem = itemfilter.first;
        
            // Called when user dropped the item. You can now request the data.
            // Note that data must be requested before the performDrop callback
            // is over.
            for (final item in event.session.items) {
              // data reader is available now
              final reader = item.dataReader;
        
              if (reader == null) {
                return;
              }
        
              reader.getValue(Formats.fileUri, (fileUri) async {
                final uriPath = fileUri?.toFilePath();
        
                if (uriPath == null) {
                  return;
                }
        
                if (adbItem.type != 'd') {
                  return;
                }
        
                final uploaded = await ref
                    .read(fsOpsProvider(adbItem, serial).notifier)
                    .pushPaths([uriPath]);
        
                if (uploaded) {
                  await displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Success'),
                        content: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: p.basename(uriPath)),
                              const TextSpan(text: " has been uploaded"),
                            ],
                          ),
                        ),
                        action: IconButton(
                          icon: const Icon(FluentIcons.dismiss_24_regular),
                          onPressed: close,
                        ),
                        severity: InfoBarSeverity.success,
                      );
                    },
                  );
                } else {
                  await displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Error'),
                        content: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: "Failed to copy "),
                              TextSpan(text: p.basename(uriPath)),
                            ],
                          ),
                        ),
                        action: IconButton(
                          icon: const Icon(FluentIcons.dismiss_24_regular),
                          onPressed: close,
                        ),
                        severity: InfoBarSeverity.error,
                      );
                    },
                  );
                }
              });
            }
          },
          child: asyncListing.when(
            data: (data) {
              if (data.isEmpty) {
                return Center(
                  child: Text(
                    "This folder is empty.",
                    style: context.textTheme.labelMedium,
                  ),
                );
              }

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = data.elementAt(index);
                  // print(lookupMimeType(item.path));

                  return FsListTile(
                    key: ValueKey(item.path),
                    item: item,
                    selected: index == selectedIndex.value,
                    onTap: (value) {
                      selectedIndex.value = index;
                    },
                  );
                },
              );
            },
            error: (error, stackTrace) {
              if (error is AdbShellLsPermissionDenied) {
                return Center(
                  child: Text(error.toString()),
                );
              }
              return Center(
                child: Text("🥴🥴🥴🤮\n${error.toString()}"),
              );
            },
            loading: () {
              return const Center(
                child: ProgressRing(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class DirectoryFlyout extends ConsumerWidget {
  const DirectoryFlyout({
    super.key,
    required this.item,
    required this.serial,
  });
  final AdbFsItem item;
  final String? serial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuFlyout(
      items: [
        MenuFlyoutSubItem(
          leading: const Icon(FluentIcons.content_view_24_regular),
          text: const Text('View'),
          items: (context) {
            return [
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.apps_list_detail_24_regular),
                text: const Text('List'),
                onPressed: () async {
                  if (context.mounted) {
                    Flyout.of(context).close();
                  }
                },
              ),
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.grid_24_regular),
                text: const Text('Grid'),
                onPressed: () async {
                  if (context.mounted) {
                    Flyout.of(context).close();
                  }
                },
              ),
            ];
          },
        ),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.arrow_sync_24_regular),
          text: const Text('Refresh'),
          onPressed: () {
            ref.invalidate(
              listDirectoryProvider(item.path, device: serial),
            );
            Flyout.of(context).close();
          },
        ),
        const MenuFlyoutSeparator(),
        MenuFlyoutSubItem(
          leading: const Icon(FluentIcons.arrow_upload_24_regular),
          text: const Text('Upload'),
          items: (context) {
            return [
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.document_multiple_24_regular),
                text: const Text('Files'),
                onPressed: () async {
                  if (item.type != 'd') {
                    return;
                  }

                  await ref
                      .read(fsOpsProvider(item, serial).notifier)
                      .pickAndPushFiles();

                  if (context.mounted) {
                    Flyout.of(context).close();
                  }
                },
              ),
              MenuFlyoutItem(
                leading: const Icon(FluentIcons.folder_24_regular),
                text: const Text('Folder'),
                onPressed: () async {
                  if (item.type != 'd') {
                    return;
                  }

                  await ref
                      .read(fsOpsProvider(item, serial).notifier)
                      .pushFolder();

                  if (context.mounted) {
                    Flyout.of(context).close();
                  }
                },
              ),
            ];
          },
        ),
      ],
    );
  }
}
