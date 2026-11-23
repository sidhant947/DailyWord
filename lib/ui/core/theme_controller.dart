import 'package:material_ui/material_ui.dart';
import '../../data/services/local_storage_service.dart';

class ThemeController extends ChangeNotifier {
  final LocalStorageService _storage;
  late ThemeMode _themeMode;

  ThemeController(this._storage) {
    final saved = _storage.getThemeMode();
    switch (saved) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;
    notifyListeners();

    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.saveThemeMode(str);
  }
}
