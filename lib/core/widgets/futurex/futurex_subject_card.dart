import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_list_card.dart';
import 'package:flutter/material.dart';

class FuturexSubjectCard extends StatelessWidget {
  const FuturexSubjectCard({
    super.key,
    required this.title,
    this.subtitle,
    this.progress,
    this.imageUrl,
    this.leadingIcon,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final double? progress;
  final String? imageUrl;
  final IconData? leadingIcon;
  final Color? iconColor;
  final VoidCallback? onTap;

  static IconData iconForSubject(String name) {
    final n = name.toLowerCase();
    if (n.contains('math')) return Icons.calculate_rounded;
    if (n.contains('english')) return Icons.menu_book_rounded;
    if (n.contains('physics')) return Icons.science_rounded;
    if (n.contains('chemistry')) return Icons.biotech_rounded;
    if (n.contains('biology')) return Icons.eco_rounded;
    if (n.contains('geography')) return Icons.public_rounded;
    if (n.contains('history')) return Icons.history_edu_rounded;
    return Icons.school_rounded;
  }

  static Color colorForSubject(String name) {
    final n = name.toLowerCase();
    if (n.contains('math')) return const Color(0xFF1565C0);
    if (n.contains('english')) return const Color(0xFF6A1B9A);
    if (n.contains('physics')) return const Color(0xFF2E7D32);
    if (n.contains('chemistry')) return const Color(0xFFE65100);
    if (n.contains('biology')) return const Color(0xFFC2185B);
    if (n.contains('geography')) return const Color(0xFF00695C);
    if (n.contains('history')) return const Color(0xFF5D4037);
    return FuturexColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final ic = leadingIcon ?? iconForSubject(title);
    final col = iconColor ?? colorForSubject(title);
    final pct = progress?.clamp(0, 100) ?? 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFF0F172A).withValues(alpha: 0.06);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.25)
        : const Color(0xFF0F172A).withValues(alpha: 0.04);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF475569);
    final arrowBg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final arrowColor = isDark ? Colors.white54 : const Color(0xFF475569);
    final progressBg = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              col.withValues(alpha: isDark ? 0.25 : 0.15),
                              col.withValues(alpha: isDark ? 0.12 : 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: col.withValues(alpha: isDark ? 0.2 : 0.1),
                            width: 1,
                          ),
                        ),
                        child: Icon(ic, color: isDark ? col.withValues(alpha: 0.9) : col, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: arrowBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: arrowColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (progress != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: col,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 6,
                            backgroundColor: progressBg,
                            color: col,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chapter row with optional index badge and progress.
class FuturexChapterCard extends StatelessWidget {
  const FuturexChapterCard({
    super.key,
    required this.title,
    required this.index,
    this.progress,
    this.accentColor,
    this.onTap,
  });

  final String title;
  final int index;
  final double? progress;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final col = accentColor ?? FuturexColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressBg = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    return FuturexListCard(
      title: title,
      badge: 'Chapter $index',
      iconColor: col,
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [col, col.withValues(alpha: 0.75)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$index',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      subtitle: progress != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 100) / 100,
                minHeight: 6,
                backgroundColor: progressBg,
                color: FuturexColors.success,
              ),
            )
          : null,
    );
  }
}

/// Topic row with play/learn affordance.
class FuturexTopicCard extends StatelessWidget {
  const FuturexTopicCard({
    super.key,
    required this.title,
    required this.index,
    this.onTap,
  });

  final String title;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FuturexListCard(
      title: title,
      badge: 'Topic $index',
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: FuturexColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.play_circle_outline_rounded,
          color: FuturexColors.primary,
          size: 26,
        ),
      ),
    );
  }
}

/// @deprecated Use [FuturexListCard] — kept for compatibility.
class FuturexSimpleListCard extends StatelessWidget {
  const FuturexSimpleListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FuturexListCard(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
