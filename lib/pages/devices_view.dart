import 'package:adb_file_explorer/adb/adb.dart';
import 'package:adb_file_explorer/components/shimmered.dart';
import 'package:adb_file_explorer/utils/extensions.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layout/layout.dart';

class DevicesListView extends ConsumerWidget {
  const DevicesListView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDevices = ref.watch(devicesProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            Builder(
              builder: (context) {
                final textTheme = context.textTheme.labelLarge;
                final letterSpacing = textTheme?.letterSpacing;
                return Text(
                  "Devices",
                  style: textTheme?.copyWith(
                    letterSpacing: letterSpacing == null
                        ? letterSpacing
                        : letterSpacing * 1.3,
                    color: textTheme.color?.withOpacity(.5),
                  ),
                );
              },
            ),
          ],
        ),
        Expanded(
          child: asyncDevices.when(
            data: (data) {
              return ListView.separated(
                itemCount: data.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
                itemBuilder: (BuildContext context, int index) {
                  final item = data.elementAt(index);

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
            },
            error: (error, stackTrace) {
              return const Center(
                child: Text("Oops! Something went wrong"),
              );
            },
            loading: () {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Shimmered(
                      height: 14.0,
                      width: 100.0,
                      color: context.colorScheme.surfaceContainerHigh,
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}

class DevicesGridView extends ConsumerWidget {
  const DevicesGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDevices = ref.watch(streamedDevicesProvider);

    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: context.layout.value(
        xs: (() {
          final width = context.layout.width;
          if (width < 300) {
            return 1;
          }

          if (width < 400) {
            return 2;
          }

          return 3;
        })(),
        sm: (() {
          final width = context.layout.width;

          if (width < 700) {
            return 3;
          }
          if (width < 900) {
            return 4;
          }

          return 5;
        })(),
        md: (() {
          final width = context.layout.width;

          if (width < 1200) {
            return 6;
          }

          return 8;
        })(),
      ),
      childAspectRatio: 3 / 4,
      mainAxisSpacing: 12.0,
      crossAxisSpacing: 12.0,
    );
    return ScaffoldPage.withPadding(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) {
                  final textTheme = context.textTheme.labelLarge;
                  final letterSpacing = textTheme?.letterSpacing;
                  return Text(
                    "Devices",
                    style: textTheme?.copyWith(
                      letterSpacing: letterSpacing == null
                          ? letterSpacing
                          : letterSpacing * 1.3,
                      color: textTheme.color?.withOpacity(.5),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          const Divider(),
          const SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: asyncDevices.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(
                    child: Text("No devices detected."),
                  );
                }

                return GridView.builder(
                  gridDelegate: gridDelegate,
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = data.elementAt(index);

                    return DeviceGridTile(
                      child: Text(
                        item.product,
                        style: context.textTheme.labelMedium,
                      ),
                      onPressed: () {
                        final devicePath = "/devices/${item.serialNumber}";
                        GoRouter.of(context).go(devicePath);
                      },
                    );
                  },
                );
              },
              error: (error, stackTrace) {
                return const Center(
                  child: Text("Oops! Something went wrong"),
                );
              },
              loading: () {
                return GridView.builder(
                  gridDelegate: gridDelegate,
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    return DeviceGridTile(
                      onPressed: null,
                      child: Shimmered(
                        height: context.textTheme.labelMedium?.fontSize,
                        width: 80.0,
                        color: context.colorScheme.onSurface.withOpacity(.5),
                        baseColor:
                            context.colorScheme.onSurface.withOpacity(.5),
                        highlightColor:
                            context.colorScheme.onSurface.withOpacity(.8),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceGridTile extends ConsumerWidget {
  const DeviceGridTile({
    super.key,
    required this.child,
    this.onPressed,
  });
  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Button(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Icon(
                  FluentIcons.phone_48_filled,
                  size: 80,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
