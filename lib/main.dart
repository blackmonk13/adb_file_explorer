import 'package:android_mate/app.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  
  runApp(
    ProviderScope(
      child: AmApp(
        arguments: arguments,
      ),
    ),
  );

  doWhenWindowReady(
    () {
      final win = appWindow;
      const initialSize = Size(1024, 576);
      win.minSize = const Size(450, 300);
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = "AndroidMate";
      win.show();
    },
  );
}
