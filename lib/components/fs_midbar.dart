import 'package:android_mate/components/fs_breadcrumbs.dart';
import 'package:android_mate/components/fs_searchbar.dart';
import 'package:android_mate/services/fs.dart';
import 'package:android_mate/utils/common.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FsMidBar extends ConsumerWidget {
  const FsMidBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 2.0,
        horizontal: 8.0,
      ),
      width: context.screenWidth,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(FluentIcons.back),
            onPressed: () {
              popFs(ref);
            },
          ),
          const Expanded(
            child: FsBreadCrumbs(),
          ),
          const FsSearchBar(),
        ],
      ),
    );
  }
}
