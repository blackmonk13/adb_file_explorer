import 'package:android_mate/utils/common.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final closeButtonColors = WindowButtonColors(
  mouseOver: Colors.red,
  iconNormal: Colors.white,
);

class WinHeader extends ConsumerStatefulWidget {
  const WinHeader({super.key});

  @override
  ConsumerState<WinHeader> createState() => _WinHeaderState();
}

class _WinHeaderState extends ConsumerState<WinHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.0,
      width: context.screenWidth,
      child: Row(
        children: [
          Expanded(
            child: WindowTitleBarBox(
              child: MoveWindow(),
            ),
          ),
          MinimizeWindowButton(
            colors: buttonColors,
          ),
          appWindow.isMaximized
              ? RestoreWindowButton(
                  colors: buttonColors,
                  onPressed: maximizeOrRestore,
                )
              : MaximizeWindowButton(
                  colors: buttonColors,
                  onPressed: maximizeOrRestore,
                ),
          CloseWindowButton(
            colors: closeButtonColors,
          ),
        ],
      ),
    );
  }

  WindowButtonColors get buttonColors {
    return WindowButtonColors(
      iconNormal: Colors.white,
      mouseOver: Colors.white.withOpacity(.1),
    );
  }

  void maximizeOrRestore() {
    appWindow.maximizeOrRestore();
    // ref.invalidate(maximizedProvider);
  }
}
