import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyStreak = 'dailyword_streak';
  static const String _keyMaxStreak = 'dailyword_max_streak';
  static const String _keyLastDailyDate = 'dailyword_last_daily_date';
  static const String _keyLastDailyGuesses = 'dailyword_last_daily_guesses';
  static const String _keyLastDailyWon = 'dailyword_last_daily_won';
  static const String _keyThemeMode = 'dailyword_theme_mode';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  int getStreak() {
    return _prefs.getInt(_keyStreak) ?? 0;
  }

  int getMaxStreak() {
    return _prefs.getInt(_keyMaxStreak) ?? 0;
  }

  String? getLastDailyDate() {
    return _prefs.getString(_keyLastDailyDate);
  }

  List<String> getLastDailyGuesses() {
    return _prefs.getStringList(_keyLastDailyGuesses) ?? [];
  }

  bool getLastDailyWon() {
    return _prefs.getBool(_keyLastDailyWon) ?? false;
  }

  bool isDailyCompletedToday([DateTime? date]) {
    final targetDate = date?.toUtc() ?? DateTime.now().toUtc();
    final dateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
    return getLastDailyDate() == dateStr;
  }

  Future<void> saveDailyGame({
    required String date,
    required List<String> guesses,
    required bool won,
    required int streak,
    required int maxStreak,
  }) async {
    await _prefs.setString(_keyLastDailyDate, date);
    await _prefs.setStringList(_keyLastDailyGuesses, guesses);
    await _prefs.setBool(_keyLastDailyWon, won);
    await _prefs.setInt(_keyStreak, streak);
    await _prefs.setInt(_keyMaxStreak, maxStreak);
  }

  Future<void> saveStreak(int streak) async {
    await _prefs.setInt(_keyStreak, streak);
  }

  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'system';
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }
}
