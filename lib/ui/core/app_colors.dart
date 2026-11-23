import 'package:material_ui/material_ui.dart';

class AppColors {
  static const Color correct = Color(0xFF488A58);
  static const Color present = Color(0xFFD49B35);
  static const Color absent = Color(0xFF7C838A);
  static const Color textLight = Color(0xFFFFFFFF);

  static const Color tileBackground = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color emptyBorder = Color(0xFFD8DCE0);
  static const Color activeBorder = Color(0xFF6B7280);
  static const Color keyBackground = Color(0xFFE5E8EB);
  static const Color divider = Color(0xFFE5E8EB);

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121213)
          : const Color(0xFFFFFFFF);

  static Color dialogBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF18181A)
          : const Color(0xFFFFFFFF);

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFF8F9FA)
          : const Color(0xFF1A1C1E);

  static Color emptyBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2E2F33)
          : const Color(0xFFD8DCE0);

  static Color activeBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF56575A)
          : const Color(0xFF6B7280);

  static Color keyBackgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2B2C30)
          : const Color(0xFFE5E8EB);

  static Color dividerColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF222326)
          : const Color(0xFFE5E8EB);
}
