import 'package:adb_file_explorer/adb/adb.dart';
import 'package:adb_file_explorer/models/adbdevice.dart';
import 'package:adb_file_explorer/utils/extensions.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;

import 'device_storages.dart';

class DeviceShell extends HookConsumerWidget {
  const DeviceShell({
    super.key,
    required this.child,
    this.serial,
  });
  final Widget child;
  final String? serial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showing = useState<bool>(false);
    ref.listen(streamedDevicesProvider, (prev, next) {
      final devices = next.valueOrNull;

      if (showing.value) {
        return;
      }

      if (devices == null) {
        showContentDialog(
          context,
          onClose: (value) {
            showing.value = false;
          },
        );
        showing.value = true;
        return;
      }

      if (devices.isEmpty) {
        showContentDialog(
          context,
          onClose: (value) {
            showing.value = false;
          },
        );
        showing.value = true;
        return;
      }

      final currentList =
          devices.where((dev) => dev.serialNumber == serial).toList();

      if (currentList.isEmpty) {
        showContentDialog(
          context,
          onClose: (value) {
            showing.value = false;

            if (value == null) {
              return;
            }

            if (['ok', 'cancel'].contains(value)) {
              context.go('/devices');
            }
          },
        );
        showing.value = true;
        return;
      }

      if (showing.value) {
        Navigator.pop(context);
        showing.value = false;
      }
    });

    final pathSegments = GoRouterState.of(context).uri.pathSegments;

    List<BreadcrumbItem<String>> breadcrumbs = _buildBreadcrumbs(pathSegments);

    return ScaffoldPage.withPadding(
      header: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  icon: const Icon(
                    FluentIcons.chevron_left_24_regular,
                  ),
                ),
                const SizedBox(width: 6.0),
                IconButton(
                  onPressed: () {
                    final beforeLastIndex =
                        breadcrumbs.indexOf(breadcrumbs.last) - 1;
                    if (beforeLastIndex == -1) {
                      return;
                    }

                    final beforeLast = breadcrumbs.elementAt(beforeLastIndex);

                    context.go(beforeLast.value);
                  },
                  icon: const Icon(
                    FluentIcons.arrow_up_24_regular,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Divider(
                  direction: Axis.vertical,
                ),
                Expanded(
                  child: BreadcrumbBar(
                    items: breadcrumbs,
                    onItemPressed: (value) {
                      context.go(value.value);
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: child,
          )
        ],
      ),
      bottomBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ).copyWith(bottom: 4.0),
        child: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              onPressed: () {},
              icon: const Icon(
                FluentIcons.apps_list_detail_24_regular,
              ),
            ),
            CommandBarButton(
              onPressed: () {},
              icon: const Icon(
                FluentIcons.grid_24_regular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showContentDialog(
    BuildContext context, {
    required ValueChanged<String?> onClose,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => DeviceMissingDialog(
        serial: serial,
      ),
    );

    onClose(result);
  }

  List<BreadcrumbItem<String>> _buildBreadcrumbs(List<String> pathSegments) {
    print(pathSegments);
    final breadcrumbs = <BreadcrumbItem<String>>[];

    for (final segment in pathSegments) {
      final segmentIndex = pathSegments.indexOf(segment);
      String segmentPath = '';

      if (segmentIndex <= 1) {
        segmentPath = pathSegments.sublist(0, segmentIndex + 1).join('/');

        breadcrumbs.add(_breadcrumb(
          label: segment,
          value: segmentPath,
        ));
      } else {
        final subSegments = segment.split('/').map((el) {
          if (el.isEmpty) {
            return '/';
          }
          return el;
        }).toList();
        for (final subSegment in subSegments) {
          var context = p.Context(style: p.Style.posix);
          final subIndex = subSegments.indexOf(subSegment);
          final subPath = subSegments.sublist(0, subIndex + 1).join('/');
          final encodedSegment =
              Uri.encodeComponent(context.normalize(subPath));

          segmentPath = [
            pathSegments.sublist(0, segmentIndex).join('/'),
            encodedSegment,
          ].join('/');

          breadcrumbs.add(_breadcrumb(
            label: subSegment,
            value: segmentPath,
          ));
        }
      }
    }

    return breadcrumbs;
  }

  BreadcrumbItem<String> _breadcrumb({
    required String label,
    required String value,
  }) {
    return BreadcrumbItem(
      label: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(label),
      ),
      value: "/$value",
    );
  }
}

class DeviceMissingDialog extends HookConsumerWidget {
  const DeviceMissingDialog({
    super.key,
    this.serial,
  });
  final String? serial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDevices = ref.watch(streamedDevicesProvider);
    final devices = asyncDevices.valueOrNull;

    useEffect(() {
      if (devices == null) {
        return null;
      }

      if (devices.where((e) => e.serialNumber == serial).isNotEmpty) {
        Navigator.pop(context, 'Device Reconnected');
      }
      return null;
    }, [devices]);

    return ContentDialog(
      title: const Text('Device disconnected'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              text:
                  'Your device seems to have been disconnected. Try reconnecting it to continue.',
              children: devices == null
                  ? null
                  : [
                      if (devices.isNotEmpty)
                        const TextSpan(
                          text:
                              ' Optionally pick another device from the following:',
                        ),
                    ],
            ),
          ),
          if (devices != null)
            Expanded(
              child: DevicesList(
                devices: devices,
              ),
            )
        ],
      ),
      actions: [
        Button(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context, 'ok');
          },
        ),
        FilledButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, 'cancel'),
        ),
      ],
    );
  }
}

class DevicesList extends StatelessWidget {
  const DevicesList({
    super.key,
    required this.devices,
  });

  final List<AdbDevice> devices;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      itemCount: devices.length,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
      itemBuilder: (BuildContext context, int index) {
        final item = devices.elementAt(index);

        return ListTile(
          onPressed: () {
            final devicePath = "/devices/${item.serialNumber}";
            GoRouter.of(context).go(devicePath);
          },
          leading: const Icon(
            FluentIcons.phone_24_regular,
          ),
          title: Text(
            item.product,
            style: context.textTheme.labelMedium,
          ),
        );
      },
    );
  }
}

class DeviceView extends ConsumerWidget {
  const DeviceView({
    super.key,
    this.serial,
  });
  final String? serial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DeviceStorages(
            serial: serial,
          ),
        )
      ],
    );
  }
}
