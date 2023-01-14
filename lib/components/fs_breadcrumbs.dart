import 'dart:async';

import 'package:android_mate/adb_fs/main.dart';
import 'package:android_mate/devices/main.dart';
import 'package:android_mate/providers/common.dart';
import 'package:android_mate/services/fs.dart';
import 'package:android_mate/utils/common.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as pth;

final editModeProvider = StateProvider<bool>(
  (ref) {
    return false;
  },
);

class FsBreadCrumbs extends ConsumerStatefulWidget {
  const FsBreadCrumbs({Key? key}) : super(key: key);

  @override
  ConsumerState<FsBreadCrumbs> createState() => _FsBreadCrumbsState();
}

class _FsBreadCrumbsState extends ConsumerState<FsBreadCrumbs> {
  TextEditingController tex = TextEditingController();
  FocusNode focusNode = FocusNode();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(
      () {
        if (!focusNode.hasFocus) {
          print("TextField lost focus");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(currentPathProvider);
    ref.watch(deviceProvider);
    final editMode = ref.watch(editModeProvider);

    return GestureDetector(
      onTap: () {
        ref.read(editModeProvider.notifier).state = !editMode;
        tex.text = ref.read(currentPathProvider).path;
      },
      child: Focus(
        onFocusChange: (value) {
          if (value) {
            return;
          }
          ref.read(editModeProvider.notifier).state = !editMode;
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.themeData.borderInputColor.withOpacity(.1),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: editMode ? textField : crumbs,
        ),
      ),
    );
  }

  List<Map<String, String>> get breadcrumbs {
    final bpaths = [
      "/",
      ...ref.read(currentPathProvider).path.substring(1).split('/')
    ];
    final List<Map<String, String>> bcpath = [];

    String newPath = "";
    for (String element in bpaths) {
      newPath = pth.join(newPath, element).replaceAll('\\', '/');
      bcpath.add({element: newPath});
    }
    bcpath.removeWhere((element) => element.keys.first.isEmpty);
    return bcpath;
  }

  Widget get crumbs {
    return ListView.builder(
      // shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: breadcrumbs.length,
      itemBuilder: (context, index) {
        final isCurrent = breadcrumbs[index].values.first ==
            ref.read(currentPathProvider).path;
        return SplitButtonBar(
          style: SplitButtonThemeData(
            borderRadius: BorderRadius.zero,
            primaryButtonStyle: ButtonStyle(
              padding: ButtonState.all(EdgeInsets.zero),
              elevation: ButtonState.all(0),
              backgroundColor: ButtonState.all(Colors.transparent),
              shape: ButtonState.all(const RoundedRectangleBorder()),
            ),
            actionButtonStyle: ButtonStyle(
              padding: ButtonState.all(EdgeInsets.zero),
              elevation: ButtonState.all(0),
              backgroundColor: ButtonState.all(Colors.transparent),
              shape: ButtonState.all(const RoundedRectangleBorder()),
            ),
          ),
          buttons: [
            Button(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  // vertical: 4.0,
                  horizontal: 8.0,
                ),
                child: Text(
                  breadcrumbs[index].keys.first,
                ),
              ),
              onPressed: () async {
                if (isCurrent) {
                  return;
                }
                ref.read(currentPathProvider.notifier).state =
                    await fsItemFromPath(breadcrumbs[index].values.first);
                goToFs(
                  ref,
                  fsPath: breadcrumbs[index].values.first,
                );
              },
            ),
            FolderDropDown(
              pathname: breadcrumbs[index].values.first,
            ),
          ],
        );
      },
    );
  }

  Widget get textField {
    return AutoSuggestBox<String>.form(
      controller: tex,
      focusNode: focusNode,
      textInputAction: TextInputAction.done,
      onChanged: (text, reason) {
        _timer?.cancel();
        _timer = Timer(
          const Duration(seconds: 2),
          () async {
            final newPath = pth.normalize(text).replaceAll('\\', '/');
            ref.read(currentPathProvider.notifier).state =
                await fsItemFromPath(newPath);
            goToFs(
              ref,
              fsPath: newPath,
            );
          },
        );
      },
      onSelected: (value) {
        print(tex.text);
      },
      items: breadcrumbs.where(
        (element) {
          return element.values.first != ref.read(currentPathProvider).path;
        },
      ).map(
        (crmb) {
          return AutoSuggestBoxItem(
            value: crmb.values.first,
            label: crmb.values.first,
          );
        },
      ).toList(),
    );
  }
}

class FolderDropDown extends ConsumerWidget {
  const FolderDropDown({
    Key? key,
    required this.pathname,
    this.selected,
  }) : super(key: key);
  final String? selected;
  final String pathname;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentPathProvider);
    ref.watch(deviceProvider);
    final lsf = ref.watch(fsProvider(pathname));

    return DropDownButton(
      trailing: const Icon(
        FluentIcons.chevron_right_med,
        size: 10.0,
      ),
      items: lsf.when(
        data: (data) {
          final foldersOnly = data.where(
            (element) {
              return element.fileType == FsType.folder;
            },
          );

          if (foldersOnly.isEmpty) {
            return [
              MenuFlyoutItem(
                text: const Text('Empty Folder'),
                onPressed: () {},
              ),
            ];
          }

          return foldersOnly.map(
            (item) {
              return MenuFlyoutItem(
                text: Text(item.name),
                onPressed: () {
                  ref.read(currentPathProvider.notifier).state = item;
                  ref.read(itemCountProvider.notifier).state = item.items;
                  goToFs(
                    ref,
                    fsPath: item.path,
                  );
                },
              );
            },
          ).toList();
        },
        error: (error, stackTrace) {
          return [
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.error),
              text: const Text('Error'),
              onPressed: () {},
            ),
          ];
        },
        loading: () {
          return [
            MenuFlyoutItem(
              leading: const ProgressRing(),
              text: const Text('Loading...'),
              onPressed: () {},
            ),
          ];
        },
      ),
    );
  }
}
