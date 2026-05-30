import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:flutter/material.dart';

/// Content card used on concept / exercise / QA tabs and forms.
class FuturexContentCard extends StatelessWidget {
  const FuturexContentCard({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.only(bottom: 14),
  });

  final Widget child;
  final String? title;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.22 : 0.02);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
