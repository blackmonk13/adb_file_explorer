part of adb_fs;

class SelectedFsNotifier extends StateNotifier<List<AdbFsItem>> {
  SelectedFsNotifier() : super([]);

  void addItem(AdbFsItem item) {
    if (state.contains(item)) {
      return;
    }
    state = [...state, item];
  }

  void addItems(List<AdbFsItem> items) {
    final newItems = items.where(
      (element) => !state.contains(element),
    );
    state = [...state, ...newItems];
  }

  void addSingle(AdbFsItem item) {
    state = [item];
  }

  void removeItem(AdbFsItem item) {
    final withoutItem = state.where((element) => element != item).toList();
    state = withoutItem;
  }

  void clear() {
    state = [];
  }
}

final selectedFsProvider =
    StateNotifierProvider<SelectedFsNotifier, List<AdbFsItem>>(
  (ref) {
    return SelectedFsNotifier();
  },
);

final multiselectFsProvider = StateProvider<bool>(
  (ref) {
    return false;
  },
);

final currentPathProvider = StateProvider<AdbFsItem>(
  (ref) {
    return AdbFsItem(
      name: "root",
      fileType: FsType.folder,
      path: "/",
      date: DateTime.now(),
      size: 0,
    );
  },
);

final fsSortKeyProvider = StateProvider.family<String, String>(
  (ref, path) {
    return "";
  },
);

final fsSortOrderProvider = StateProvider.family<bool, String>(
  (ref, path) {
    return false;
  },
);

final fsProvider = FutureProvider.family<List<AdbFsItem>, String>(
  (ref, path) async {
    final fsKey = ref.watch(fsSortKeyProvider(path));
    final fsOrder = ref.watch(fsSortOrderProvider(path));

    final cresult = await listFolder(path);

    if (fsKey.isEmpty) {
      return cresult;
    }
    return sortAdbLsOutput(cresult, fsKey, fsOrder);
  },
);
