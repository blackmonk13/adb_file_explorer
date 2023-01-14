import 'package:android_mate/colorscheme.dart';
import 'package:android_mate/pages/apk_install.dart';
import 'package:android_mate/pages/fs_browser.dart';
import 'package:android_mate/pages/fs_push.dart';
import 'package:android_mate/utils/theme.dart';
import 'package:fluent_ui/fluent_ui.dart';

class AmApp extends StatelessWidget {
  const AmApp({
    Key? key,
    required this.arguments,
  }) : super(key: key);
  final List<String> arguments;

  String get initialRoute {
    if (arguments.isEmpty) {
      return "/home";
    }
    final firstArg = arguments.first;
    return "/${firstArg.toLowerCase().trim()}";
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: "AndroidMate",
      debugShowCheckedModeBanner: false,
      darkTheme: darkTheme,
      theme: lightTheme,
      themeMode: ThemeMode.dark,
      initialRoute: initialRoute,
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case "/install":
            builder = (context) {
              return const ApkInstall();
            };
            break;
          case "/push":
            builder = (context) {
              return const FsPush();
            };
            break;
          default:
            builder = (context) {
              return const FsBrowser();
            };
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

final darkTheme = colorSchemeToThemeData(
  colorScheme: flexSchemeDark,
);

final lightTheme = colorSchemeToThemeData(
  colorScheme: flexSchemeLight,
);
