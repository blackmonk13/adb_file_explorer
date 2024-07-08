import 'package:adb_file_explorer/adb/adb.dart';
import 'package:adb_file_explorer/providers/router.dart';

import 'package:adb_file_explorer/utils/extensions.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:layout/layout.dart';
import 'package:system_theme/system_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return Layout(
      format: MaterialLayoutFormat(),
      child: FluentApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        title: 'File Explorer',
        theme: FluentThemeData(
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        ),
        darkTheme: FluentThemeData(
          accentColor: SystemTheme.accentColor.accent.toAccentColor(),
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
      ),
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
    final asyncDevices = ref.watch(streamedDevicesProvider);

    final List<NavigationPaneItem> items = asyncDevices.when(
      data: (data) {
        return [
          ...data.map(
            (e) => PaneItem(
              key: ValueKey(e.serialNumber),
              onTap: () => context.go("/devices/${e.serialNumber}"),
              icon: const Icon(
                FluentIcons.phone_24_filled,
                size: 20.0,
              ),
              title: Text(
                e.product,
                style: context.textTheme.labelMedium,
              ),
              body: const SizedBox.shrink(),
            ),
          )
        ];
      },
      error: (error, stackTrace) => [],
      loading: () => [],
    );

    return Scaffold(
      body: NavigationView(
        key: viewKey,
        // appBar: NavigationAppBar(
        //   title: Text.rich(
        //     TextSpan(
        //       children: [
        //         TextSpan(text: context.layout.breakpoint.name),
        //         TextSpan(text: context.layout.width.toString()),
        //       ],
        //     ),
        //   ),
        // ),
        paneBodyBuilder: (item, desc) {
          final name =
              item?.key is ValueKey ? (item!.key as ValueKey).value : null;
          return FocusTraversalGroup(
            key: ValueKey('body$name'),
            child: child,
          );
        },
        pane: NavigationPane(
          selected: _selectedIndex(items, context),
          displayMode: context.layout.value(
            xs: PaneDisplayMode.compact,
            sm: PaneDisplayMode.open,
          ),
          size: const NavigationPaneSize(
            openMaxWidth: 220.0,
            openMinWidth: 200.0,
          
          ),
          items: [
            PaneItemHeader(
              key: const Key('/devices'),
              header: const Text(
                "Devices",
              ),
            ),
            PaneItemSeparator(),
            ...items,
            // PaneItemSeparator(),
            // PaneItemHeader(
            //   header: const Text("Bookmarks"),
            // ),
            // PaneItem(
            //   icon: const Icon(
            //     FluentIcons.bookmark_24_filled,
            //     size: 20.0,
            //   ),
            //   title: Text("Music"),
            //   body: const SizedBox.shrink(),
            // ),
          ],
        ),
      ),
    );
  }

  int? _selectedIndex(List<NavigationPaneItem> items, BuildContext context) {
    final deviceSerial = GoRouterState.of(context).pathParameters['serial'];

    if (deviceSerial == null) {
      return null;
    }

    final foundIndex = items.indexWhere((e) => e.key == Key(deviceSerial));

    if (foundIndex == -1 || foundIndex >= items.length) {
      return null;
    }

    return foundIndex;
  }
}
