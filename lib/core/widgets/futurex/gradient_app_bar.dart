import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gradient top app bar used across the app.
///
/// Uses a non-const constructor so field changes can hot-reload when possible.
/// After adding/removing parameters, run **hot restart** (not hot reload) once.
@immutable
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Non-const constructor: avoids hot-reload failures when fields change.
  // ignore: prefer_const_constructors_in_immutables
  GradientAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showNotificationIcon = false,
    this.onNotificationPressed,
    this.leading,
    this.implyLeading = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showNotificationIcon;
  final VoidCallback? onNotificationPressed;
  final Widget? leading;

  /// When false, no back button is shown unless [leading] is set.
  final bool implyLeading;

  static const double _subtitleExtraHeight = 22;

  @override
  Size get preferredSize {
    final base = kToolbarHeight;
    if (subtitle != null && subtitle!.isNotEmpty) {
      return Size.fromHeight(base + _subtitleExtraHeight);
    }
    return Size.fromHeight(base);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && implyLeading && canPop) {
      effectiveLeading = IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Navigator.maybePop(context),
      );
    }

    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return AppBar(
      leading: effectiveLeading,
      automaticallyImplyLeading: false,
      toolbarHeight: hasSubtitle ? kToolbarHeight + _subtitleExtraHeight : kToolbarHeight,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 19,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasSubtitle)
            Text(
              subtitle!,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: [
        if (showNotificationIcon)
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: onNotificationPressed,
          ),
        ...?actions,
      ],
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FuturexColors.gradientStart, FuturexColors.gradientEnd],
          ),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: FuturexColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}
