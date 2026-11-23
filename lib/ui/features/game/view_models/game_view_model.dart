import 'package:material_ui/material_ui.dart';
import '../../../../data/repositories/word_repository.dart';
import '../../../../domain/models/game_mode.dart';
import '../../../../domain/models/letter_evaluation.dart';

class GameViewModel extends ChangeNotifier {
  final WordRepository wordRepository;
  final GameMode mode;

  late String _targetWord;
  final List<String> _guesses = [];
  final List<List<LetterEvaluation>> _evaluations = [];
  final Map<String, LetterEvaluation> _keyStatuses = {};
  String _currentInput = '';
  bool _isGameOver = false;
  bool _isGameWon = false;
  String? _toastMessage;
  int? _shakingRowIndex;

  GameViewModel({
    required this.wordRepository,
    required this.mode,
  }) {
    initializeGame();
  }

  String get targetWord => _targetWord;
  List<String> get guesses => List.unmodifiable(_guesses);
  List<List<LetterEvaluation>> get evaluations => List.unmodifiable(_evaluations);
  Map<String, LetterEvaluation> get keyStatuses => Map.unmodifiable(_keyStatuses);
  String get currentInput => _currentInput;
  bool get isGameOver => _isGameOver;
  bool get isGameWon => _isGameWon;
  String? get toastMessage => _toastMessage;
  int? get shakingRowIndex => _shakingRowIndex;
  int get dailyNumber => wordRepository.getDailyNumber();

  void initializeGame() {
    _targetWord = wordRepository.getTargetWord(mode);
    _guesses.clear();
    _evaluations.clear();
    _keyStatuses.clear();
    _currentInput = '';
    _isGameOver = false;
    _isGameWon = false;
    _toastMessage = null;
    _shakingRowIndex = null;

    if (mode == GameMode.daily && wordRepository.isDailyCompletedToday()) {
      final savedGuesses = wordRepository.getTodayDailyGuesses();
      for (final guess in savedGuesses) {
        final eval = wordRepository.evaluateGuess(
          target: _targetWord,
          guess: guess,
        );
        _guesses.add(guess);
        _evaluations.add(eval);
        _updateKeyStatuses(guess, eval);
      }
      _isGameOver = true;
      _isGameWon = wordRepository.getTodayDailyWon();
      _toastMessage = _isGameWon ? 'Already solved today!' : 'Already played today!';
    }

    notifyListeners();
  }

  void onKey(String key) {
    if (_isGameOver) {
      return;
    }

    if (key == 'ENTER') {
      submitGuess();
    } else if (key == 'BACKSPACE') {
      if (_currentInput.isNotEmpty) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        notifyListeners();
      }
    } else {
      if (_currentInput.length < 5 && RegExp(r'^[A-Z]$').hasMatch(key)) {
        _currentInput += key;
        notifyListeners();
      }
    }
  }

  void submitGuess() {
    if (_currentInput.length < 5) {
      _triggerShake(_guesses.length);
      _showToast('Not enough letters');
      return;
    }

    if (!wordRepository.isValidGuess(_currentInput)) {
      _triggerShake(_guesses.length);
      _showToast('Not in word list');
      return;
    }

    final guess = _currentInput;
    final eval = wordRepository.evaluateGuess(
      target: _targetWord,
      guess: guess,
    );

    _guesses.add(guess);
    _evaluations.add(eval);
    _currentInput = '';
    _updateKeyStatuses(guess, eval);

    if (guess == _targetWord) {
      _isGameOver = true;
      _isGameWon = true;
      if (mode == GameMode.daily) {
        wordRepository.recordDailyGame(guesses: _guesses, won: true);
      }
      final phrases = [
        'Genius!',
        'Magnificent!',
        'Impressive!',
        'Splendid!',
        'Great!',
        'Phew!'
      ];
      _showToast(phrases[_guesses.length - 1]);
    } else if (_guesses.length == 6) {
      _isGameOver = true;
      _isGameWon = false;
      if (mode == GameMode.daily) {
        wordRepository.recordDailyGame(guesses: _guesses, won: false);
      }
      _showToast(_targetWord);
    }

    notifyListeners();
  }

  void _updateKeyStatuses(String guess, List<LetterEvaluation> eval) {
    for (var i = 0; i < 5; i++) {
      final char = guess[i];
      final current = _keyStatuses[char];
      final newStatus = eval[i];

      if (current == LetterEvaluation.correct) {
        continue;
      }
      if (newStatus == LetterEvaluation.correct) {
        _keyStatuses[char] = LetterEvaluation.correct;
      } else if (newStatus == LetterEvaluation.present &&
          current != LetterEvaluation.correct) {
        _keyStatuses[char] = LetterEvaluation.present;
      } else if (newStatus == LetterEvaluation.absent && current == null) {
        _keyStatuses[char] = LetterEvaluation.absent;
      }
    }
  }

  void _triggerShake(int rowIndex) {
    _shakingRowIndex = rowIndex;
    notifyListeners();
  }

  void clearShake() {
    _shakingRowIndex = null;
    notifyListeners();
  }

  void _showToast(String message) {
    _toastMessage = message;
    notifyListeners();
  }

  void clearToast() {
    _toastMessage = null;
    notifyListeners();
  }
}
