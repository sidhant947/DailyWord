import 'package:material_ui/material_ui.dart';
import '../../../core/app_colors.dart';

class HowToPlayView extends StatelessWidget {
  const HowToPlayView({super.key});

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: AppColors.background(context),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.text(context)),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              'HOW TO PLAY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: AppColors.text(context),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                Text(
                  'Guess the word in 6 tries.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '• Each guess must be a valid 5-letter word.\n'
                  '• The color of the tiles will change to show how close your guess was to the word.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.text(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: AppColors.dividerColor(context)),
                ),
                Text(
                  'Examples',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(context),
                  ),
                ),
                const SizedBox(height: 16),
                _buildExampleRow(
                  context: context,
                  letters: ['W', 'E', 'A', 'R', 'Y'],
                  highlightIndex: 0,
                  highlightColor: AppColors.correct,
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 14, color: AppColors.text(context)),
                    children: const [
                      TextSpan(
                        text: 'W',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' is in the word and in the correct spot (Green).',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildExampleRow(
                  context: context,
                  letters: ['P', 'I', 'L', 'L', 'S'],
                  highlightIndex: 1,
                  highlightColor: AppColors.present,
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 14, color: AppColors.text(context)),
                    children: const [
                      TextSpan(
                        text: 'I',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' is in the word but in the wrong spot (Yellow).',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildExampleRow(
                  context: context,
                  letters: ['V', 'A', 'G', 'U', 'E'],
                  highlightIndex: 3,
                  highlightColor: AppColors.absent,
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 14, color: AppColors.text(context)),
                    children: const [
                      TextSpan(
                        text: 'U',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' is not in the word in any spot (Gray).',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: AppColors.dividerColor(context)),
                ),
                const Text(
                  'A new Daily Challenge is available every day at 00:00 UTC.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.absent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExampleRow({
    required BuildContext context,
    required List<String> letters,
    required int highlightIndex,
    required Color highlightColor,
  }) {
    return Row(
      children: List.generate(letters.length, (index) {
        final isHighlighted = index == highlightIndex;
        final color = isHighlighted
            ? highlightColor
            : AppColors.background(context);
        final borderColor = isHighlighted
            ? highlightColor
            : AppColors.emptyBorderColor(context);
        final textColor =
            isHighlighted ? AppColors.textLight : AppColors.text(context);

        return Container(
          width: 42,
          height: 42,
          margin: const EdgeInsets.only(right: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            letters[index],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        );
      }),
    );
  }
}
