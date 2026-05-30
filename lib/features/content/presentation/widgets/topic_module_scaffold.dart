import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-screen wrapper for a single topic learning module (notes, quiz, etc.).
class TopicModuleScaffold extends StatelessWidget {
  const TopicModuleScaffold({
    super.key,
    required this.topicName,
    required this.moduleTitle,
    required this.child,
    this.moduleSubtitle,
    this.headerColor,
  });

  final String topicName;
  final String moduleTitle;
  final String? moduleSubtitle;
  final Color? headerColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: moduleTitle,
        subtitle: moduleSubtitle ?? topicName,
      ),
      body: child,
    );
  }
}

/// Accent colors for learning module cards on the topic hub.
class TopicModuleStyle {
  const TopicModuleStyle({
    required this.icon,
    required this.color,
    required this.gradient,
  });

  final IconData icon;
  final Color color;
  final List<Color> gradient;

  static const objectives = TopicModuleStyle(
    icon: Icons.flag_rounded,
    color: Color(0xFF1565C0),
    gradient: [Color(0xFF42A5F5), Color(0xFF1565C0)],
  );

  static const notes = TopicModuleStyle(
    icon: Icons.auto_stories_rounded,
    color: Color(0xFF6A1B9A),
    gradient: [Color(0xFFAB47BC), Color(0xFF6A1B9A)],
  );

  static const videos = TopicModuleStyle(
    icon: Icons.play_circle_fill_rounded,
    color: Color(0xFFC62828),
    gradient: [Color(0xFFEF5350), Color(0xFFC62828)],
  );

  static const exercise = TopicModuleStyle(
    icon: Icons.fitness_center_rounded,
    color: Color(0xFF2E7D32),
    gradient: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
  );

  static const quiz = TopicModuleStyle(
    icon: Icons.quiz_rounded,
    color: Color(0xFFE65100),
    gradient: [Color(0xFFFFA726), Color(0xFFE65100)],
  );

  static const exam = TopicModuleStyle(
    icon: Icons.assignment_rounded,
    color: Color(0xFF4527A0),
    gradient: [Color(0xFF7E57C2), Color(0xFF4527A0)],
  );

  static const qa = TopicModuleStyle(
    icon: Icons.forum_rounded,
    color: Color(0xFF00695C),
    gradient: [Color(0xFF26A69A), Color(0xFF00695C)],
  );

  static const reports = TopicModuleStyle(
    icon: Icons.report_rounded,
    color: Color(0xFFAD1457),
    gradient: [Color(0xFFEC407A), Color(0xFFAD1457)],
  );
}

class TopicModuleCard extends StatelessWidget {
  const TopicModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.style,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final TopicModuleStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: style.gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: style.color.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(style.icon, color: Colors.white, size: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Open',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white.withValues(alpha: 0.95),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TopicModuleListTile extends StatelessWidget {
  const TopicModuleListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.style,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final TopicModuleStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF475569);
    final chevronColor = isDark ? Colors.white30 : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: style.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: style.color.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(style.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: chevronColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
