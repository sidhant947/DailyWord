import 'package:material_ui/material_ui.dart';
import '../../../core/app_colors.dart';
import '../../../core/theme_controller.dart';

class SettingsView extends StatelessWidget {
  final ThemeController themeController;

  const SettingsView({
    super.key,
    required this.themeController,
  });

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
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.text(context),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              'SETTINGS',
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
                  'THEME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.absent,
                  ),
                ),
                const SizedBox(height: 12),
                ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.dividerColor(context),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildThemeOption(
                            context: context,
                            title: 'Follow System',
                            subtitle: 'Match device light or dark mode',
                            icon: Icons.brightness_auto_outlined,
                            mode: ThemeMode.system,
                            isSelected:
                                themeController.themeMode == ThemeMode.system,
                            showDivider: true,
                          ),
                          _buildThemeOption(
                            context: context,
                            title: 'Light Mode',
                            subtitle: 'Classic white background',
                            icon: Icons.light_mode_outlined,
                            mode: ThemeMode.light,
                            isSelected:
                                themeController.themeMode == ThemeMode.light,
                            showDivider: true,
                          ),
                          _buildThemeOption(
                            context: context,
                            title: 'Dark Mode',
                            subtitle: 'Dark surface for night play',
                            icon: Icons.dark_mode_outlined,
                            mode: ThemeMode.dark,
                            isSelected:
                                themeController.themeMode == ThemeMode.dark,
                            showDivider: false,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => themeController.setThemeMode(mode),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppColors.correct : AppColors.text(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.absent,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: AppColors.correct,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.dividerColor(context),
          ),
      ],
    );
  }
}
