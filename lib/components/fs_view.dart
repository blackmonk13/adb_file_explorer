import 'package:android_mate/adb_fs/main.dart';
import 'package:android_mate/providers/common.dart';
import 'package:android_mate/services/fs.dart';
import 'package:android_mate/utils/common.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:share_plus/share_plus.dart';

class FsView extends ConsumerWidget {
  const FsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Navigator(
      key: fsNavKey,
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/files/:filePath':
            final filePath = settings.arguments.toString();
            builder = (BuildContext _) => FsContent(
                  filePath: filePath,
                );
            break;
          default:
            builder = (BuildContext _) => const FsContent(
                  filePath: "/",
                );
            break;
        }
        return FluentPageRoute(
          builder: builder,
          settings: settings,
        );
      },
    );
  }
}

class FsContent extends ConsumerStatefulWidget {
  const FsContent({
    Key? key,
    this.filePath = "/",
  }) : super(key: key);
  final String filePath;

  @override
  ConsumerState<FsContent> createState() => _FsContentState();
}

class _FsContentState extends ConsumerState<FsContent> {
  @override
  Widget build(BuildContext context) {
    final currentPath = ref.watch(currentPathProvider);
    final lsf = ref.watch(fsProvider(currentPath.path));
    return CustomScrollView(
      slivers: <Widget>[
        lsf.when(
          data: (data) {
            if (data.isEmpty) {
              return _boxChild(
                child: Center(
                  child: SizedBox.square(
                    dimension: 210,
                    child: Expander(
                      headerHeight: 100,
                      header: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(FluentIcons.open_folder_horizontal),
                          Text('No Files'),
                        ],
                      ),
                      content: const Text(
                        "No files or you don't have adequate permission to view files in this folder.",
                      ),
                    ),
                  ),
                ),
              );
            }

            return FsGridTiles(items: data);
          },
          error: (error, stackTrace) {
            return _boxChild(
              child: const Center(
                child: Text(
                  "Unexpected Error Occured",
                ),
              ),
            );
          },
          loading: () {
            return _boxChild(
              child: const Center(child: ProgressRing()),
            );
          },
        )
      ],
    );
  }

  Widget _boxChild({required Widget child}) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: child,
    );
  }
}

class FsGridTiles extends ConsumerWidget {
  const FsGridTiles({
    super.key,
    required this.items,
  });
  final List<AdbFsItem> items;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areas = ref.watch(splitAreasProvider);
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return TilesFsItem(
            item: items[index],
          );
        },
        childCount: items.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount(areas),
        childAspectRatio: childAspectRatio(areas),
      ),
    );
  }

  int crossAxisCount(List<double?> areas) {
    if (areas.isEmpty) {
      return 3;
    }
    final size = areas.last;

    if (size == null) {
      return 3;
    }
    if (size.compareTo(.8) > 0) {
      return 4;
    }
    if (size.compareTo(.7) > 0) {
      return 3;
    }
    if (size.compareTo(.5) > 0) {
      return 2;
    }
    if (size.compareTo(.4) > 0) {
      return 1;
    }
    return 1;
  }

  double childAspectRatio(List<double?> areas) {
    if (areas.isEmpty) {
      return 4 / 1.3;
    }
    final size = areas.last;
    // print(size);
    if (size == null) {
      return 4 / 1.3;
    }
    if (size.compareTo(.7) > 0) {
      return 5 / 1.3;
    }
    if (size.compareTo(.5) > 0) {
      return 5 / 1;
    }
    return 5 / 1;
  }
}

class TilesFsItem extends ConsumerStatefulWidget {
  const TilesFsItem({
    Key? key,
    required this.item,
  }) : super(key: key);
  final AdbFsItem item;

  @override
  ConsumerState<TilesFsItem> createState() => _TilesFsItem();
}

class _TilesFsItem extends ConsumerState<TilesFsItem> {
  AdbFsItem get item {
    return widget.item;
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = ref.watch(selectedFsProvider);
    final multiselect = ref.watch(multiselectFsProvider);
    return GestureDetector(
      onLongPress: () {
        context.showSnackBar(message: "LongPress");
      },
      onDoubleTap: () async {
        switch (item.fileType) {
          case FsType.folder:
            ref.read(currentPathProvider.notifier).state = item;
            ref.read(itemCountProvider.notifier).state = item.items;
            goToFs(
              ref,
              fsPath: item.path,
            );
            break;
          case FsType.file:
            break;
          case FsType.link:
            if (item.linkType == FsLinkType.folder) {
              ref.read(currentPathProvider.notifier).state = item;
              ref.read(itemCountProvider.notifier).state = item.items;
              goToFs(
                ref,
                fsPath: item.path,
              );
            }
            break;
          default:
            toggleLoad(true);
            await viewFile(
              item: item,
              ref: ref,
            );
            toggleLoad(false);
            break;
        }
      },
      // TODO: Update syntax
      // child: Flyout(
      //   navigatorKey: fsNavKey,
      //   onOpen: () {
      //     if (multiselect) {
      //       return;
      //     }
      //     selectItem();
      //   },
      //   content: (context) {
      //     return MenuFlyout(
      //       items: multiselect ? multiItemMenu : singleItemMenu,
      //     );
      //   },
      //   openMode: FlyoutOpenMode.secondaryPress,
      //   child: ListTile.selectable(
      //     selected: selectedItems.contains(item),
      //     leading: Icon(
      //       leadIcon(item.fileType, item.path),
      //       color: context.themeData.accentColor,
      //     ),
      //     onPressed: () {
      //       selectItem();
      //       // context.showSnackBar(message: pressedKey ?? 'No key pressed');
      //     },
      //     onSelectionChange: (value) {
      //       selectItem();
      //     },
      //     selectionMode: multiselect
      //         ? ListTileSelectionMode.multiple
      //         : ListTileSelectionMode.single,
      //     title: Text(
      //       item.name,
      //       softWrap: false,
      //       overflow: TextOverflow.ellipsis,
      //       maxLines: 2,
      //       style: context.textTheme.body,
      //     ),
      //   ),
      // ),
    );
  }

  List<MenuFlyoutItemBase> get singleItemMenu {
    final multiselect = ref.read(multiselectFsProvider);
    return [
      MenuFlyoutItem(
        leading: Icon(
          item.fileType == FsType.folder
              ? FluentIcons.open_folder_horizontal
              : FluentIcons.open_file,
        ),
        text: const Text('Open'),
        onPressed: () async {
          switch (item.fileType) {
            case FsType.folder:
              ref.read(currentPathProvider.notifier).state = item;
              ref.read(itemCountProvider.notifier).state = item.items;
              goToFs(
                ref,
                fsPath: item.path,
              );
              break;
            case FsType.file:
              break;
            case FsType.link:
              if (item.linkType == FsLinkType.folder) {
                ref.read(currentPathProvider.notifier).state = item;
                ref.read(itemCountProvider.notifier).state = item.items;
                goToFs(
                  ref,
                  fsPath: item.path,
                );
              }
              break;
            default:
              toggleLoad(true);
              await viewFile(
                item: item,
                ref: ref,
              );
              toggleLoad(false);
              break;
          }
        },
      ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.rename),
        text: const Text('Rename'),
        onPressed: () {},
      ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.multi_select),
        text: const Text('Select'),
        onPressed: () {
          selectItem();
          ref.read(multiselectFsProvider.notifier).state = !multiselect;
        },
      ),
      const MenuFlyoutSeparator(),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.copy),
        text: const Text('Copy'),
        onPressed: () {},
      ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.save_as),
        text: const Text('Save As'),
        onPressed: () async {
          String? savedPath;
          toggleLoad(true);
          if (item.fileType == FsType.folder) {
            savedPath = await saveFolder(item: item);
          } else {
            savedPath = await saveFile(item: item);
          }
          toggleLoad(false);

          if (savedPath == null) {
            return;
          }

          if (!mounted) return;
          context.showSnackBar(message: "Saved to $savedPath");
        },
      ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.delete),
        text: const Text('Delete'),
        onPressed: () {},
      ),
      const MenuFlyoutSeparator(),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.clipboard_list_add),
        text: const Text('Copy Path'),
        onPressed: () {
          context.copyToClipboard(message: item.path);
        },
      ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.share),
        text: const Text('Share'),
        onPressed: () async {
          toggleLoad(true);
          final savedFile = await saveToTemp(item);
          toggleLoad(false);
          if (savedFile == null) {
            return;
          }
          Share.shareXFiles(
            [
              XFile(savedFile),
            ],
            text: item.name,
          );
          return;
        },
      ),
    ];
  }

  List<MenuFlyoutItemBase> get multiItemMenu {
    final selectedItems = ref.read(selectedFsProvider);
    final multiselect = ref.read(multiselectFsProvider);
    return [
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.rename),
        text: const Text('Rename'),
        onPressed: () {},
      ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.multi_select),
        text: Text(
          selectedItems.contains(item) ? 'Deselect' : 'Select',
        ),
        onPressed: () {
          selectItem();
        },
      ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.select_all),
        text: const Text('Select None'),
        onPressed: () {
          ref.read(selectedFsProvider.notifier).clear();
          ref.read(multiselectFsProvider.notifier).state = false;
        },
      ),
      const MenuFlyoutSeparator(),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.copy),
        text: const Text('Copy'),
        onPressed: () {},
      ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.save_as),
        text: const Text('Save As'),
        onPressed: () async {
          String? savedPath;
          toggleLoad(true);
          if (item.fileType == FsType.folder) {
            savedPath = await saveFolder(item: item);
          } else {
            savedPath = await saveFile(item: item);
          }
          toggleLoad(false);

          if (savedPath == null) {
            return;
          }

          if (!mounted) return;
          context.showSnackBar(message: "Saved to $savedPath");
        },
      ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.delete),
        text: const Text('Delete'),
        onPressed: () {},
      ),
      const MenuFlyoutSeparator(),
      // TODO: Update syntax
      // MenuFlyoutSubItem(
      //   leading: const Icon(FluentIcons.clipboard_list_add),
      //   text: const Text('Copy Path'),
      //   items: [
      //     MenuFlyoutItem(
      //       text: const Text('With Comma'),
      //       onPressed: () {
      //         if (selectedItems.isEmpty) {
      //           return;
      //         }

      //         context.copyToClipboard(message: selectedItems.join(","));
      //       },
      //     ),
      //     MenuFlyoutItem(
      //       text: const Text('With Newline'),
      //       onPressed: () {
      //         if (selectedItems.isEmpty) {
      //           return;
      //         }
      //         context.copyToClipboard(message: selectedItems.join("\n"));
      //       },
      //     ),
      //   ],
      // ),
      MenuFlyoutItem(
        leading: const Icon(FluentIcons.share),
        text: const Text('Share'),
        onPressed: () async {
          Share.shareXFiles(
            selectedItems.map(
              (e) {
                return XFile(e.path);
              },
            ).toList(),
            text: selectedItems.map(
              (e) {
                return e.name;
              },
            ).join(", "),
          );
        },
      ),
    ];
  }

  void selectItem() {
    final multiselect = ref.read(multiselectFsProvider);
    final hasItem = ref.read(selectedFsProvider).contains(item);
    if (hasItem) {
      ref.read(selectedFsProvider.notifier).removeItem(item);
      return;
    }
    if (multiselect) {
      ref.read(selectedFsProvider.notifier).addItem(item);
      return;
    }
    ref.read(selectedFsProvider.notifier).addSingle(item);
  }

  void toggleLoad(bool status) {
    ref.read(loadStateProvider.notifier).state = status;
  }
}
