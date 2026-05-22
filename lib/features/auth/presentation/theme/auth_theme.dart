import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nexa-style auth palette (matches nexatrackerprod auth screens).
class AuthTheme {
  static const Color darkBlue = Color(0xFF123D6A);
  static const Color primaryBlue = Color(0xFF2378D0);
  static const Color green = Color(0xFF27AE60);
  static const Color primaryGreen = Color(0xFF4DBC81);
  static const Color bgGradientStart = Color(0xFF001A14);
  static const Color bgGradientEnd = Color(0xFF003D33);
  static const Color neonGreen = Color(0xFF00FFA3);
  static const Color labelColor = Color(0xCC123D6A);
  static const Color hintColor = Color(0x99123D6A);
  static const Color fieldBorder = Color(0x1A2378D0);

  static TextStyle titleOnBg(BuildContext context) => GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w500,
      );

  static TextStyle headlineOnBg(BuildContext context) => GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w600,
      );

  static TextStyle fieldLabel() => GoogleFonts.outfit(
        color: labelColor,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      );

  static TextStyle footer() => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryGreen,
      );

  static InputDecoration pillDecoration({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: const BorderSide(color: fieldBorder, width: 2),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: hintColor),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle(BuildContext context) =>
      ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .0125,
        ),
        textStyle: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      );

  static ButtonStyle welcomeFilledStyle(BuildContext context) =>
      ElevatedButton.styleFrom(
        backgroundColor: green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        side: const BorderSide(color: Colors.white, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .0175,
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
}
