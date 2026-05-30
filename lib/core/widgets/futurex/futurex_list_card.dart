import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern tappable row card for chapters, topics, bookmarks, etc.
class FuturexListCard extends StatelessWidget {
  const FuturexListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.badge,
    this.icon = Icons.chevron_right_rounded,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final String? badge;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = iconColor ?? FuturexColors.primary;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final iconSecondary = isDark ? Colors.white38 : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: accent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          subtitle!,
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing ?? Icon(icon, color: iconSecondary, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
