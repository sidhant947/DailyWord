import '../../domain/models/game_mode.dart';
import '../../domain/models/letter_evaluation.dart';
import '../services/local_storage_service.dart';
import '../services/word_service.dart';

abstract class WordRepository {
  String getTargetWord(GameMode mode, [DateTime? date]);
  int getDailyNumber([DateTime? date]);
  bool isValidGuess(String word);
  List<LetterEvaluation> evaluateGuess({
    required String target,
    required String guess,
  });
  int getStreak();
  int getMaxStreak();
  bool isDailyCompletedToday([DateTime? date]);
  List<String> getTodayDailyGuesses([DateTime? date]);
  bool getTodayDailyWon([DateTime? date]);
  Future<void> recordDailyGame({
    required List<String> guesses,
    required bool won,
    DateTime? date,
  });
}

class WordRepositoryImpl implements WordRepository {
  final WordService _wordService;
  final LocalStorageService _storage;

  WordRepositoryImpl({
    WordService? wordService,
    required LocalStorageService storageService,
  })  : _wordService = wordService ?? WordService(),
        _storage = storageService;

  @override
  String getTargetWord(GameMode mode, [DateTime? date]) {
    return mode == GameMode.daily
        ? _wordService.getDailyWord(date)
        : _wordService.getRandomWord();
  }

  @override
  int getDailyNumber([DateTime? date]) {
    return _wordService.getDailyNumber(date);
  }

  @override
  bool isValidGuess(String word) {
    return _wordService.isValidWord(word);
  }

  @override
  int getStreak() {
    final streak = _storage.getStreak();
    final lastDateStr = _storage.getLastDailyDate();
    if (lastDateStr == null || streak == 0) {
      return 0;
    }
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final parts = lastDateStr.split('-').map(int.parse).toList();
    final lastDate = DateTime.utc(parts[0], parts[1], parts[2]);
    final diff = today.difference(lastDate).inDays;
    if (diff > 1) {
      return 0;
    }
    return streak;
  }

  @override
  int getMaxStreak() {
    return _storage.getMaxStreak();
  }

  @override
  bool isDailyCompletedToday([DateTime? date]) {
    return _storage.isDailyCompletedToday(date);
  }

  @override
  List<String> getTodayDailyGuesses([DateTime? date]) {
    if (!isDailyCompletedToday(date)) {
      return [];
    }
    return _storage.getLastDailyGuesses();
  }

  @override
  bool getTodayDailyWon([DateTime? date]) {
    if (!isDailyCompletedToday(date)) {
      return false;
    }
    return _storage.getLastDailyWon();
  }

  @override
  Future<void> recordDailyGame({
    required List<String> guesses,
    required bool won,
    DateTime? date,
  }) async {
    final targetDate = date?.toUtc() ?? DateTime.now().toUtc();
    final today = DateTime.utc(targetDate.year, targetDate.month, targetDate.day);
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final lastDateStr = _storage.getLastDailyDate();
    int currentStreak = _storage.getStreak();
    int maxStreak = _storage.getMaxStreak();

    if (won) {
      if (lastDateStr != null) {
        final parts = lastDateStr.split('-').map(int.parse).toList();
        final lastDate = DateTime.utc(parts[0], parts[1], parts[2]);
        final diff = today.difference(lastDate).inDays;
        if (diff == 0) {
          return;
        } else if (diff == 1) {
          currentStreak += 1;
        } else {
          currentStreak = 1;
        }
      } else {
        currentStreak = 1;
      }
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
    } else {
      currentStreak = 0;
    }

    await _storage.saveDailyGame(
      date: dateStr,
      guesses: guesses,
      won: won,
      streak: currentStreak,
      maxStreak: maxStreak,
    );
  }

  @override
  List<LetterEvaluation> evaluateGuess({
    required String target,
    required String guess,
  }) {
    final result = List<LetterEvaluation>.filled(5, LetterEvaluation.absent);
    final targetCounts = <String, int>{};

    for (var i = 0; i < 5; i++) {
      final char = target[i];
      targetCounts[char] = (targetCounts[char] ?? 0) + 1;
    }

    for (var i = 0; i < 5; i++) {
      if (guess[i] == target[i]) {
        result[i] = LetterEvaluation.correct;
        targetCounts[guess[i]] = targetCounts[guess[i]]! - 1;
      }
    }

    for (var i = 0; i < 5; i++) {
      if (result[i] == LetterEvaluation.correct) {
        continue;
      }
      final char = guess[i];
      if ((targetCounts[char] ?? 0) > 0) {
        result[i] = LetterEvaluation.present;
        targetCounts[char] = targetCounts[char]! - 1;
      } else {
        result[i] = LetterEvaluation.absent;
      }
    }

    return result;
  }
}
