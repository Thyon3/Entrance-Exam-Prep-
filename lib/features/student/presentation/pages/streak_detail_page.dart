import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakDetailPage extends StatelessWidget {
  const StreakDetailPage({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.streakData,
  });

  final int currentStreak;
  final int longestStreak;
  final dynamic streakData;

  @override
  Widget build(BuildContext context) {
    final isOnFire = currentStreak >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Streak',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Main streak flame card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: currentStreak > 0
                      ? [const Color(0xFFFF9500), const Color(0xFFFF3B00)]
                      : [const Color(0xFFB0BEC5), const Color(0xFF78909C)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: (currentStreak > 0
                            ? const Color(0xFFFF9500)
                            : Colors.grey)
                        .withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Flame icon
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      currentStreak > 0
                          ? Icons.local_fire_department_rounded
                          : Icons.local_fire_department_outlined,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$currentStreak',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentStreak == 1 ? 'DAY STREAK' : 'DAY STREAK',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOnFire ? '🔥 You\'re on fire! Keep going!' : currentStreak > 0 ? '💪 Great start! Build the habit.' : '😴 Start your streak today!',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFFFFB300),
                    value: '$longestStreak',
                    label: 'Longest Streak',
                    bgColor: const Color(0xFFFFF9E6),
                    borderColor: const Color(0xFFFFE082),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    icon: Icons.calendar_today_rounded,
                    iconColor: FuturexColors.primary,
                    value: '$currentStreak',
                    label: 'Current Streak',
                    bgColor: const Color(0xFFF0EEFF),
                    borderColor: FuturexColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Weekly calendar heatmap
            _buildWeeklyCalendar(),

            const SizedBox(height: 24),

            // Tips card
            _buildTipsCard(currentStreak),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    final today = DateTime.now();
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // Simulate which days have been active based on streak count
    final activeDays = currentStreak.clamp(0, 7);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_rounded, size: 18, color: FuturexColors.primary),
              const SizedBox(width: 8),
              Text(
                'This Week',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayDate = today.subtract(Duration(days: today.weekday - 1 - index));
              final isToday = dayDate.day == today.day &&
                  dayDate.month == today.month &&
                  dayDate.year == today.year;
              final isFuture = dayDate.isAfter(today);
              // Mark as active if within streak range
              final isActive = !isFuture && index >= (7 - activeDays);

              return Column(
                children: [
                  Text(
                    days[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isToday ? FuturexColors.primary : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [Color(0xFFFF9500), Color(0xFFFF3B00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isActive ? null : isFuture ? const Color(0xFFF1F5F9) : const Color(0xFFF1F5F9),
                      border: isToday
                          ? Border.all(color: FuturexColors.primary, width: 2)
                          : null,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF9500).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isActive
                          ? const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 18)
                          : isFuture
                              ? const Icon(Icons.lock_outline_rounded, color: Color(0xFFCBD5E1), size: 14)
                              : Text(
                                  '${dayDate.day}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(int streak) {
    final String tip;
    final IconData tipIcon;
    if (streak == 0) {
      tip = 'Start studying today! Even 10 minutes a day builds momentum.';
      tipIcon = Icons.rocket_launch_rounded;
    } else if (streak < 3) {
      tip = 'Great start! Try to study at the same time every day to build a solid habit.';
      tipIcon = Icons.tips_and_updates_rounded;
    } else if (streak < 7) {
      tip = 'You\'re building momentum! Weekend sessions are key — don\'t break the chain!';
      tipIcon = Icons.bolt_rounded;
    } else {
      tip = 'Incredible streak! You\'re in the top students. Keep crushing those sessions!';
      tipIcon = Icons.workspace_premium_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FuturexColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FuturexColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tipIcon, color: FuturexColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF3730A3),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
