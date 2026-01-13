enum ViewMode { grid, list }

enum SortOption { nameAsc, nameDesc }

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
    }
  }
}
