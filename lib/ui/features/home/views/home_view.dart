import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/repositories/word_repository.dart';
import '../../../../domain/models/game_mode.dart';
import '../../../core/app_colors.dart';
import '../../../core/theme_controller.dart';
import '../../game/view_models/game_view_model.dart';
import '../../game/views/game_view.dart';
import '../../how_to_play/views/how_to_play_view.dart';
import '../../settings/views/settings_view.dart';

class HomeView extends StatefulWidget {
  final WordRepository wordRepository;
  final ThemeController themeController;

  const HomeView({
    super.key,
    required this.wordRepository,
    required this.themeController,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final streak = widget.wordRepository.getStreak();
    final isDailySolved = widget.wordRepository.isDailyCompletedToday();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: AppColors.background(context),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.star_outline_rounded,
              color: AppColors.text(context),
            ),
            tooltip: 'GitHub',
            onPressed: () => _launch('https://github.com/sidhant947/DailyWord'),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.favorite_outline_rounded,
                color: AppColors.text(context),
              ),
              tooltip: 'Ko-fi',
              onPressed: () => _launch('https://ko-fi.com/sidhant947'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _miniTile('D', AppColors.correct),
                      _miniTile('A', AppColors.present),
                      _miniTile('I', AppColors.absent),
                      _miniTile('L', AppColors.correct),
                      _miniTile('Y', AppColors.present),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'DAILY WORD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: AppColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '6 chances to guess a 5-letter word.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.text(context).withValues(alpha: 0.7),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.dividerColor(context),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 18,
                          color: AppColors.present,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streak',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.text(context),
                        foregroundColor: AppColors.background(context),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameView(
                              viewModel: GameViewModel(
                                wordRepository: widget.wordRepository,
                                mode: GameMode.daily,
                              ),
                            ),
                          ),
                        );
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isDailySolved) ...[
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AppColors.correct,
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Text(
                            'DAILY CHALLENGE',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text(context),
                        side: BorderSide(
                          color: AppColors.text(context),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameView(
                              viewModel: GameViewModel(
                                wordRepository: widget.wordRepository,
                                mode: GameMode.random,
                              ),
                            ),
                          ),
                        );
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: const Text(
                        'RANDOM WORD',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text(context),
                        side: BorderSide(
                          color: AppColors.dividerColor(context),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HowToPlayView(),
                          ),
                        );
                      },
                      child: const Text(
                        'HOW TO PLAY',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text(context),
                        side: BorderSide(
                          color: AppColors.dividerColor(context),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsView(
                              themeController: widget.themeController,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniTile(String char, Color color) {
    return Container(
      width: 38,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        char,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
