import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showNotificationIcon = false,
    this.onNotificationPressed,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final bool showNotificationIcon;
  final VoidCallback? onNotificationPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (showNotificationIcon)
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
