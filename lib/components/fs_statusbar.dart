import 'package:android_mate/providers/common.dart';
import 'package:android_mate/utils/common.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FsStatusBar extends ConsumerStatefulWidget {
  const FsStatusBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FsStatusBarState();
}

class _FsStatusBarState extends ConsumerState<FsStatusBar> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadStateProvider);
    final itemCount = ref.watch(itemCountProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          itemCount == null
              ? const SizedBox.shrink()
              : Text("$itemCount items"),
          const Divider(),
          isLoading
              ? SizedBox(
                  width: context.screenWidth * .2,
                  child: const ProgressBar(
                    strokeWidth: 10.0,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
