import 'package:flutter/material.dart';

/// Same layout as nexatrackerprod `AuthBackground` (gradient image over dark blue).
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, this.child});
  final Widget? child;

  static const String gradientAsset = 'lib/assets/images/gradient.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFF0B0F19)),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              gradientAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0B0F19),
                      Color(0xFF1E1B4B),
                      Color(0xFF0F172A),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
