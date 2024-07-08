import 'package:adb_file_explorer/app.dart';
import 'package:adb_file_explorer/pages/device_details.dart';
import 'package:adb_file_explorer/pages/device_storages.dart';
import 'package:adb_file_explorer/pages/devices_view.dart';
import 'package:adb_file_explorer/pages/directory_listing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GlobalKey<NavigatorState> navigatorKey(NavigatorKeyRef ref, String id) {
  return GlobalKey<NavigatorState>();
}

final rootNavkey = GlobalKey<NavigatorState>();
final appShellNavkey = GlobalKey<NavigatorState>();
final deviceShellNavkey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    navigatorKey: rootNavkey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      /// Application shell
      ShellRoute(
        navigatorKey: appShellNavkey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AppShell(
            child: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return const DevicesGridView();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'devices',
                builder: (BuildContext context, GoRouterState state) {
                  return const DevicesGridView();
                },
              ),
              ShellRoute(
                navigatorKey: deviceShellNavkey,
                builder: (
                  BuildContext context,
                  GoRouterState state,
                  Widget child,
                ) {
                  return DeviceShell(
                    serial: state.pathParameters['serial'],
                    child: child,
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'devices/:serial',
                    builder: (BuildContext context, GoRouterState state) {
                      return DeviceView(
                        serial: state.pathParameters['serial'],
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':directory',
                        builder: (BuildContext context, GoRouterState state) {
                          
                          return DirectoryListing(
                            serial: state.pathParameters['serial'],
                            directory: state.pathParameters['directory'],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
