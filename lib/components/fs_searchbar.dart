import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]);

  void addHistory(String item) {
    if (state.contains(item)) {
      state = [...state.where((element) => element != item), item];
      return;
    }

    if (state.length == 10) {
      state = [...state.sublist(1), item];
    } else {
      state = [...state, item];
    }
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>(
  (ref) {
    return SearchHistoryNotifier();
  },
);

final searchItemProvider = StateProvider<String>(
  (ref) {
    return "";
  },
);

class FsSearchBar extends ConsumerStatefulWidget {
  const FsSearchBar({super.key});

  @override
  ConsumerState<FsSearchBar> createState() => _FsSearchBarState();
}

class _FsSearchBarState extends ConsumerState<FsSearchBar> {
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    ref.watch(searchItemProvider);
    final searchHistory = ref.watch(searchHistoryProvider);
    return SizedBox(
      width: 200,
      child: AutoSuggestBox<String>.form(
        onChanged: (text, reason) {
          _timer?.cancel();
          _timer = Timer(const Duration(seconds: 2), () {
            if (text.isEmpty) {
              return;
            }
            ref.read(searchItemProvider.notifier).state = text;
            ref.read(searchHistoryProvider.notifier).addHistory(text);
          });
        },
        items: searchHistory.map((sItem) {
          return AutoSuggestBoxItem<String>(
              value: sItem,
              label: sItem,
              onFocusChange: (focused) {
                if (focused) {
                  debugPrint('Focused $sItem');
                }
              });
        }).toList(),
        onSelected: (item) {
          ref.read(searchItemProvider.notifier).state = item.value ?? "";
        },
      ),
    );
  }
}
