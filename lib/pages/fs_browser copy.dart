import 'dart:io';

import 'package:android_mate/components/fs_midbar.dart';
import 'package:android_mate/components/fs_statusbar.dart';
import 'package:android_mate/components/fs_tree.dart';
import 'package:android_mate/components/fs_view.dart';
import 'package:android_mate/components/tabtoolbar.dart';
import 'package:android_mate/components/win_header.dart';
import 'package:android_mate/providers/common.dart';
import 'package:android_mate/utils/common.dart';
import 'package:android_mate/utils/theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/macos/macos_blur_view_state.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_split_view/multi_split_view.dart';

class FsBrowser extends ConsumerStatefulWidget {
  const FsBrowser({Key? key}) : super(key: key);

  @override
  ConsumerState<FsBrowser> createState() => _FsBrowserState();
}

class _FsBrowserState extends ConsumerState<FsBrowser> {
  WindowEffect effect = WindowEffect.aero;
  Color color =
      Platform.isWindows ? const Color(0xCC222222) : Colors.transparent;
  InterfaceBrightness brightness =
      Platform.isMacOS ? InterfaceBrightness.auto : InterfaceBrightness.dark;
  MacOSBlurViewState macOSBlurViewState =
      MacOSBlurViewState.followsWindowActiveState;

  final splitControl = MultiSplitViewController(
    areas: [
      Area(
        minimalSize: 150.0,
        weight: .3,
      ),
      Area(
        minimalSize: 300.0,
        weight: .7,
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    setWindowEffect(effect);
  }

  void setWindowEffect(WindowEffect? value) {
    Window.setEffect(
      effect: value!,
      color: color,
      dark: brightness == InterfaceBrightness.dark,
    );
    if (Platform.isMacOS) {
      if (brightness != InterfaceBrightness.auto) {
        Window.overrideMacOSBrightness(
            dark: brightness == InterfaceBrightness.dark);
      }
    }
    setState(() => effect = value);
  }

  void setBrightness(InterfaceBrightness brightness) {
    this.brightness = brightness;
    if (this.brightness == InterfaceBrightness.dark) {
      color = Platform.isWindows ? const Color(0xCC222222) : Colors.transparent;
    } else {
      color = Platform.isWindows ? const Color(0x22DDDDDD) : Colors.transparent;
    }
    setWindowEffect(effect);
  }

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: context.themeData.accentColor,
      child: ScaffoldPage(
        header: const WinHeader(),
        padding: const EdgeInsets.all(0),
        content: Column(
          children: [
            SizedBox(
              width: context.screenWidth,
              height: 90.0,
              child: const TabToolBar(),
            ),
            const SizedBox(
              height: 40.0,
              child: FsMidBar(),
            ),
            Expanded(
              child: MultiSplitViewTheme(
                data: MultiSplitViewThemeData(
                  dividerThickness: 3,
                ),
                child: MultiSplitView(
                  controller: splitControl,
                  onWeightChange: () {
                    ref.read(splitAreasProvider.notifier).state =
                        splitControl.areas.map(
                      (element) {
                        return element.weight;
                      },
                    ).toList();
                  },
                  dividerBuilder: (
                    axis,
                    index,
                    resizable,
                    dragging,
                    highlighted,
                    themeData,
                  ) {
                    return Container(
                      color: Colors.transparent,
                      // color: dragging
                      //     ? context.themeData.disabledColor
                      //     : context.themeData.disabledColor,
                    );
                  },
                  children: const [
                    FsTree(),
                    Acrylic(
                      luminosityAlpha: 0,
                      blurAmount: 12.0,
                      elevation: .8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            10.0,
                          ),
                          bottomLeft: Radius.circular(
                            10.0,
                          ),
                        ),
                      ),
                      child: FsView(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 25.0,
              width: context.screenWidth,
              child: const FsStatusBar(),
            ),
          ],
        ),
      ),
    );
  }
}
