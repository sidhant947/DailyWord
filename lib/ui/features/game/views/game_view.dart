import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/game_mode.dart';
import '../../../../domain/models/letter_evaluation.dart';
import '../../../core/app_colors.dart';
import '../view_models/game_view_model.dart';

class GameView extends StatefulWidget {
  final GameViewModel viewModel;

  const GameView({
    super.key,
    required this.viewModel,
  });

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _shakeController;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    widget.viewModel.addListener(_onViewModelUpdate);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelUpdate);
    _shakeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onViewModelUpdate() {
    if (widget.viewModel.shakingRowIndex != null &&
        !_shakeController.isAnimating) {
      _shakeController.forward(from: 0.0).then((_) {
        widget.viewModel.clearShake();
      });
    }

    if (widget.viewModel.toastMessage != null) {
      final message = widget.viewModel.toastMessage;
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted && widget.viewModel.toastMessage == message) {
          widget.viewModel.clearToast();
        }
      });
    }

    if (widget.viewModel.isGameOver && !_dialogShown) {
      _dialogShown = true;
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) {
          _showGameOverDialog();
        }
      });
    }
  }

  String _generateShareText() {
    final buffer = StringBuffer();
    final title = widget.viewModel.mode == GameMode.daily
        ? 'Daily Word #${widget.viewModel.dailyNumber}'
        : 'Daily Word (Random)';
    final score = widget.viewModel.isGameWon
        ? '${widget.viewModel.guesses.length}/6'
        : 'X/6';
    buffer.writeln('$title $score\n');

    for (final row in widget.viewModel.evaluations) {
      for (final eval in row) {
        switch (eval) {
          case LetterEvaluation.correct:
            buffer.write('🟩');
            break;
          case LetterEvaluation.present:
            buffer.write('🟨');
            break;
          case LetterEvaluation.absent:
            buffer.write('⬛');
            break;
        }
      }
      buffer.writeln();
    }
    buffer.writeln();
    buffer.writeln('Get Daily Word on F-Droid:');
    buffer.write('https://f-droid.org/packages/com.sidhant.dailyword/');
    return buffer.toString().trimRight();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.dialogBackground(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.dividerColor(context)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.viewModel.isGameWon
                          ? 'CONGRATULATIONS'
                          : 'GAME OVER',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: AppColors.text(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.viewModel.isGameWon
                        ? 'You solved the word in ${widget.viewModel.guesses.length}/6 tries!'
                        : 'The word was ${widget.viewModel.targetWord}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.correct,
                        foregroundColor: AppColors.textLight,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        final text = _generateShareText();
                        await Clipboard.setData(ClipboardData(text: text));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Copied result to clipboard!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                              ),
                              backgroundColor: AppColors.text(context),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          );
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'SHARE RESULT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.viewModel.mode == GameMode.random) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text(context),
                          side: BorderSide(color: AppColors.text(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () {
                          _dialogShown = false;
                          Navigator.pop(context);
                          widget.viewModel.initializeGame();
                        },
                        child: const Text(
                          'PLAY AGAIN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text(context),
                        side: BorderSide(color: AppColors.dividerColor(context)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'MAIN MENU',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        widget.viewModel.onKey('ENTER');
      } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
        widget.viewModel.onKey('BACKSPACE');
      } else {
        final char = event.character?.toUpperCase();
        if (char != null && RegExp(r'^[A-Z]$').hasMatch(char)) {
          widget.viewModel.onKey(char);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final title = widget.viewModel.mode == GameMode.daily
              ? 'Daily Challange'
              : 'Random';

          return Scaffold(
            backgroundColor: AppColors.background(context),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.dividerColor(context),
                      width: 1,
                    ),
                  ),
                ),
                child: AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.text(context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  centerTitle: true,
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.text(context),
                    ),
                  ),
                  actions: [
                    if (widget.viewModel.mode == GameMode.random)
                      IconButton(
                        icon: Icon(Icons.refresh, color: AppColors.text(context)),
                        tooltip: 'New Word',
                        onPressed: () {
                          _dialogShown = false;
                          widget.viewModel.initializeGame();
                        },
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 5 / 6,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 350,
                                maxHeight: 420,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(6, (rowIndex) {
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2.5,
                                        ),
                                        child: _buildRow(rowIndex),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildKeyboard(),
                      const SizedBox(height: 12),
                    ],
                  ),
                  if (widget.viewModel.toastMessage != null)
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.text(context),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.viewModel.toastMessage!,
                            style: TextStyle(
                              color: AppColors.background(context),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(int rowIndex) {
    Widget rowContent;
    final guesses = widget.viewModel.guesses;
    final evaluations = widget.viewModel.evaluations;
    final currentInput = widget.viewModel.currentInput;

    if (rowIndex < guesses.length) {
      final guess = guesses[rowIndex];
      final eval = evaluations[rowIndex];
      rowContent = Row(
        children: List.generate(5, (colIndex) {
          return Expanded(
            child: _buildTile(
              char: guess[colIndex],
              evaluation: eval[colIndex],
            ),
          );
        }),
      );
    } else if (rowIndex == guesses.length) {
      rowContent = Row(
        children: List.generate(5, (colIndex) {
          final char = colIndex < currentInput.length
              ? currentInput[colIndex]
              : '';
          return Expanded(
            child: _buildTile(
              char: char,
              isCurrentRow: true,
            ),
          );
        }),
      );
    } else {
      rowContent = Row(
        children: List.generate(5, (colIndex) {
          return Expanded(
            child: _buildTile(char: ''),
          );
        }),
      );
    }

    if (widget.viewModel.shakingRowIndex == rowIndex) {
      return AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final sine = sin(_shakeController.value * 3 * pi);
          return Transform.translate(
            offset: Offset(sine * 8, 0),
            child: child,
          );
        },
        child: rowContent,
      );
    }

    return rowContent;
  }

  Widget _buildTile({
    required String char,
    LetterEvaluation? evaluation,
    bool isCurrentRow = false,
  }) {
    Color backgroundColor = AppColors.background(context);
    Color borderColor = AppColors.emptyBorderColor(context);
    Color textColor = AppColors.text(context);

    if (evaluation != null) {
      textColor = AppColors.textLight;
      switch (evaluation) {
        case LetterEvaluation.correct:
          backgroundColor = AppColors.correct;
          borderColor = AppColors.correct;
          break;
        case LetterEvaluation.present:
          backgroundColor = AppColors.present;
          borderColor = AppColors.present;
          break;
        case LetterEvaluation.absent:
          backgroundColor = AppColors.absent;
          borderColor = AppColors.absent;
          break;
      }
    } else if (char.isNotEmpty) {
      borderColor = AppColors.activeBorderColor(context);
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
        alignment: Alignment.center,
        child: Text(
          char,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    const row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
    const row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
    const row3 = ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'BACKSPACE'];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            _buildKeyboardRow(row1),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _buildKeyboardRow(row2),
            ),
            const SizedBox(height: 6),
            _buildKeyboardRow(row3),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        final isSpecial = key == 'ENTER' || key == 'BACKSPACE';
        final flex = isSpecial ? 3 : 2;

        Color backgroundColor = AppColors.keyBackgroundColor(context);
        Color textColor = AppColors.text(context);

        final status = widget.viewModel.keyStatuses[key];
        if (status != null) {
          textColor = AppColors.textLight;
          switch (status) {
            case LetterEvaluation.correct:
              backgroundColor = AppColors.correct;
              break;
            case LetterEvaluation.present:
              backgroundColor = AppColors.present;
              break;
            case LetterEvaluation.absent:
              backgroundColor = AppColors.absent;
              break;
          }
        }

        Widget child;
        if (key == 'BACKSPACE') {
          child = Icon(
            Icons.backspace_outlined,
            size: 19,
            color: textColor,
          );
        } else {
          child = Text(
            key,
            style: TextStyle(
              fontSize: key == 'ENTER' ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          );
        }

        return Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: SizedBox(
              height: 54,
              child: Material(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => widget.viewModel.onKey(key),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
