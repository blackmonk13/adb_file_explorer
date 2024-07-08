import 'package:adb_file_explorer/adb/adb.dart';
import 'package:adb_file_explorer/components/shimmered.dart';
import 'package:adb_file_explorer/utils/extensions.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layout/layout.dart';
import 'package:path/path.dart';

class DeviceStorages extends ConsumerWidget {
  const DeviceStorages({
    super.key,
    this.serial,
  });
  final String? serial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storages = ['/storage/emulated/0', '/storage/sdcard1'];
    final width = context.layout.width;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.layout.value(
          xs: (() {
            if (width < 500) {
              return 1;
            }
            return 2;
          })(),
          md: 3,
        ),
        childAspectRatio: 3 / 1,
      ),
      itemCount: storages.length,
      itemBuilder: (BuildContext context, int index) {
        return DeviceStorage(
          serial: serial,
          storagePath: storages.elementAt(index),
        );
      },
    );
  }
}

class DeviceStorage extends ConsumerWidget {
  const DeviceStorage({
    super.key,
    this.serial,
    this.storagePath = "/data",
  });
  final String? serial;
  final String storagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStorageInfo = ref.watch(storageInfoProvider(
      serial: serial,
      path: storagePath,
    ));

    return asyncStorageInfo.when(
      data: (data) {
        if (data == null) {
          return const Text("🤷‍♂️🤷‍♂️🤷‍♀️🤷‍♀️");
        }

        return InkWell(
          onTap: () {
            final directoryPath = Uri.encodeComponent(
              storagePath,
            );
            context.go(
              '/devices/$serial/$directoryPath',
              extra: {'serial': serial},
            );
          },
          child: Row(
            children: [
              const Flexible(
                child: Icon(
                  FluentIcons.storage_24_regular,
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storagePath == '/storage/emulated/0'
                          ? 'Internal'
                          : 'External',
                      style: context.textTheme.labelSmall,
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    ProgressBar(
                      value: data.used / data.total * 100,
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      '${convertToLargerUnit(data.free * 1024)} free of ${convertToLargerUnit(data.total * 1024)}',
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) {
        return const Text("🥴🥴🥴🤮");
      },
      loading: () {
        return Row(
          children: [
            const Flexible(
              child: Icon(
                FluentIcons.storage_24_regular,
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmered(
                    color: context.colorScheme.surfaceContainerHigh,
                    height: context.textTheme.labelSmall?.fontSize,
                    width: 80,
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  const ProgressBar(),
                  const SizedBox(
                    height: 4.0,
                  ),
                  Shimmered(
                    color: context.colorScheme.surfaceContainerHigh,
                    height: context.textTheme.labelSmall?.fontSize,
                    width: 100,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
