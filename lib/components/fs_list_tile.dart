import 'package:adb_file_explorer/adb/adb.dart';
import 'package:adb_file_explorer/models/adbfsitem.dart';
import 'package:adb_file_explorer/providers/router.dart';
import 'package:adb_file_explorer/utils/extensions.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';

class FsListTile extends ConsumerWidget {
  const FsListTile({
    super.key,
    required this.item,
    this.selected = false,
    this.onTap,
    this.onOpen,
  });
  final AdbFsItem item;
  final bool selected;
  final ValueChanged<AdbFsItem>? onTap;
  final ValueChanged<AdbFsItem>? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextController = FlyoutController();
    final errorController = FlyoutController();
    final contextAttachKey = GlobalKey();
    final serial = GoRouterState.of(context).pathParameters['serial'];
    final asyncFsOps = ref.watch(fsOpsProvider(item, serial));
    return GestureDetector(
      onSecondaryTapUp: (d) {
        onTap?.call(item);
        // This calculates the position of the flyout according to the parent navigator
        final targetContext = contextAttachKey.currentContext;
        if (targetContext == null) return;
        final box = targetContext.findRenderObject() as RenderBox;
        final position = box.localToGlobal(
          d.localPosition,
          ancestor: Navigator.of(context).context.findRenderObject(),
        );

        contextController.showFlyout(
          barrierColor: Colors.black.withOpacity(0.1),
          position: position,
          builder: (context) {
            return FsMenuFlyout(
              item: item,
              serial: serial,
              onOpen: onOpen,
            );
          },
        );
      },
      onDoubleTap: () async {
        onOpen?.call(item);
        final directoryPath = Uri.encodeComponent(
          item.path,
        );

        if (item.type == 'd') {
          context.go(
            '/devices/$serial/$directoryPath',
            extra: {'serial': serial},
          );
          return;
        }

        if (item.type != '-') {
          return;
        }

        await ref
            .read(fsOpsProvider(
              item,
              serial,
            ).notifier)
            .viewFile();
      },
      child: FlyoutTarget(
        key: contextAttachKey,
        controller: contextController,
        child: ListTile.selectable(
          selected: selected,
          onPressed: () {
            onTap?.call(item);
          },
          leading: Icon(icon),
          trailing: asyncFsOps.when(
            data: (data) {
              return null;
            },
            error: (error, stackTrace) {
              return FlyoutTarget(
                controller: errorController,
                child: IconButton(
                  icon: Icon(
                    FluentIcons.error_circle_24_filled,
                    color: context.colorScheme.error,
                  ),
                  onPressed: () {
                    errorController.showFlyout(
                      barrierDismissible: true,
                      dismissOnPointerMoveAway: false,
                      dismissWithEsc: true,
                      navigatorKey: rootNavkey.currentState,
                      builder: (context) {
                        return FlyoutContent(
                          padding: const EdgeInsets.all(16.0),
                          constraints: const BoxConstraints(
                            maxWidth: 400,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Error",
                                  style: context.textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8.0),
                                const Divider(),
                                const SizedBox(height: 12.0),
                                Text(
                                  error.toString(),
                                  style: context.textTheme.labelMedium,
                                ),
                                const SizedBox(height: 12.0),
                                if (kDebugMode) ...[
                                  Text(
                                    stackTrace.toString(),
                                    style: context.textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 12.0),
                                ],
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Button(
                                      onPressed: () async {
                                        ref.invalidate(
                                            fsOpsProvider(item, serial));
                                        if (context.mounted) {
                                          Flyout.of(context).close();
                                        }
                                      },
                                      child: const Text('Ok'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
            loading: () {
              return const ProgressRing();
            },
          ),
          title: Text(
            item.name,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.normal,
            ),
          ),
          subtitle: Text.rich(
            TextSpan(
              children: [
                if (item.type == '-') ...[
                  TextSpan(
                    text: formatFileSize(item.size.toString()).toLowerCase(),
                  ),
                  const TextSpan(text: '\t\t'),
                ],
                TextSpan(text: formatDate(item.date)),
                // const TextSpan(text: '\t'),
                // TextSpan(text: '${lookupMimeType(item.path)}'),
              ],
            ),
            style: context.textTheme.labelSmall?.copyWith(
                // fontWeight: FontWeight.normal,
                color: context.textTheme.labelSmall?.color?.withOpacity(.4)),
          ),
        ),
      ),
    );
  }

  IconData get icon {
    switch (item.type) {
      case 'd':
        return FluentIcons.folder_24_filled;
      case 'l':
        return FluentIcons.document_link_24_filled;
      case '-':
        return fileIcon;
      default:
        return FluentIcons.document_question_mark_24_filled;
    }
  }

  IconData get fileIcon {
    final fileMime = lookupMimeType(item.path);

    if (fileMime == null) {
      return FluentIcons.document_question_mark_24_filled;
    }

    if (fileMime.startsWith('image/')) {
      return FluentIcons.image_24_filled;
    }

    if (fileMime.startsWith('text/')) {
      return FluentIcons.document_text_24_filled;
    }

    if (fileMime.startsWith('audio/')) {
      return FluentIcons.music_note_2_24_filled;
    }

    if (fileMime.startsWith('video/')) {
      return FluentIcons.video_clip_24_filled;
    }

    if (fileMime == 'application/pdf') {
      return FluentIcons.document_pdf_24_filled;
    }

    if (['application/x-rar-compressed', 'application/zip']
        .contains(fileMime)) {
      return FluentIcons.folder_zip_24_filled;
    }
    if (['application/epub+zip', 'application/x-mobipocket-ebook']
        .contains(fileMime)) {
      return FluentIcons.book_24_filled;
    }
    if (fileMime.startsWith('video/application/x-font-')) {
      return FluentIcons.text_font_24_filled;
    }

    if ([
      'application/x-msdownload',
    ].contains(fileMime)) {
      return FluentIcons.app_generic_24_filled;
    }

    if ([
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ].contains(fileMime)) {
      return FluentIcons.document_table_24_filled;
    }

    switch (item.path) {
      case 'd':
        return FluentIcons.folder_24_filled;
      case 'l':
        return FluentIcons.document_link_24_filled;
      default:
        return FluentIcons.document_question_mark_24_filled;
    }
  }
}

class FsMenuFlyout extends HookConsumerWidget {
  const FsMenuFlyout({
    super.key,
    required this.item,
    required this.serial,
    this.onOpen,
  });

  final ValueChanged<AdbFsItem>? onOpen;

  final AdbFsItem item;
  final String? serial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuFlyout(
      items: [
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.open_24_regular),
          text: const Text('Open'),
          onPressed: () async {
            if (item.type == 'l') {
              return;
            }

            if (item.type == "-") {
              await ref.read(fsOpsProvider(item, serial).notifier).viewFile();
            }

            if (item.type == "d") {
              onOpen?.call(item);
              final directoryPath = Uri.encodeComponent(
                item.path,
              );
              if (context.mounted) {
                context.go(
                  '/devices/$serial/$directoryPath',
                  extra: {'serial': serial},
                );
              }
            }

            if (context.mounted) {
              Flyout.of(context).close();
            }
          },
        ),
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.save_24_regular),
          text: Text("Save ${item.type == 'd' ? 'To' : 'As'}"),
          onPressed: () async {
            if (item.type == '-') {
              await ref.read(fsOpsProvider(item, serial).notifier).saveAs();
              return;
            }

            if (item.type == 'd') {
              await ref.read(fsOpsProvider(item, serial).notifier).saveTo();
              return;
            }

            if (context.mounted) {
              Flyout.of(context).close();
            }
          },
        ),
        if (item.type == 'd')
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
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.delete_24_regular),
          text: const Text('Delete'),
          onPressed: () async {
            if (item.type == '-') {
              await ref.read(fsOpsProvider(item, serial).notifier).deleteFile();
              return;
            }

            if (item.type == 'd') {
              await ref
                  .read(fsOpsProvider(item, serial).notifier)
                  .deleteFolder();
              return;
            }

            if (context.mounted) {
              Flyout.of(context).close();
            }
          },
        ),
        // const MenuFlyoutSeparator(),
        // MenuFlyoutItem(
        //   leading: const Icon(FluentIcons.rename_24_regular),
        //   text: const Text('Rename'),
        //   onPressed: Flyout.of(context).close,
        // ),
        // MenuFlyoutItem(
        //   leading: const Icon(FluentIcons.select_all_on_24_regular),
        //   text: const Text('Select'),
        //   onPressed: Flyout.of(context).close,
        // ),
      ],
    );
  }
}

String formatDate(DateTime dateTime) {
  final DateFormat formatter = DateFormat('MMMM d, y');
  return formatter.format(dateTime);
}
