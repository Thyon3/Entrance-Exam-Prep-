import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nexa-style auth palette (matches nexatrackerprod auth screens).
class AuthTheme {
  static const Color darkBlue = Color(0xFF4F46E5);
  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color green = Color(0xFF4F46E5);
  static const Color primaryGreen = Color(0xFF818CF8);
  static const Color bgGradientStart = Color(0xFF0B0F19);
  static const Color bgGradientEnd = Color(0xFF1E1B4B);
  static const Color neonGreen = Color(0xFF818CF8);
  static const Color labelColor = Color(0xFF0F172A);
  static const Color hintColor = Color(0x99475569);
  static const Color fieldBorder = Color(0x1F4F46E5);

  static TextStyle titleOnBg(BuildContext context) => GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle headlineOnBg(BuildContext context) => GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w600,
      );

  static TextStyle fieldLabel() => GoogleFonts.outfit(
        color: labelColor,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      );

  static TextStyle footer() => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryGreen,
      );

  static InputDecoration pillDecoration({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: hintColor),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle(BuildContext context) =>
      ElevatedButton.styleFrom(
        elevation: 4,
        shadowColor: darkBlue.withValues(alpha: 0.3),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .0175,
        ),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );

  static ButtonStyle welcomeFilledStyle(BuildContext context) =>
      ElevatedButton.styleFrom(
        backgroundColor: green,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: green.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .0175,
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );

  static ButtonStyle welcomeOutlinedStyle(BuildContext context) =>
      ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .0175,
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
}
