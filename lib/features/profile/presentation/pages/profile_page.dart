import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/shared/providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.embedded = false, this.bottomInset = 0});

  final bool embedded;
  final double bottomInset;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _currentPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final u = ref.read(authProvider).user;
    if (u != null && _first.text.isEmpty) {
      _first.text = u.firstName;
      _last.text = u.lastName;
      _phone.text = u.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _currentPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    try {
      final user = await ref.read(authRepositoryProvider).updateProfile({
        'firstName': _first.text.trim(),
        'lastName': _last.text.trim(),
        'phoneNumber': _phone.text.trim(),
      });
      ref.read(authProvider.notifier).setUser(user);
      if (mounted) Navigator.pop(context);
      _showSnack('Profile updated successfully', FuturexColors.success);
    } catch (e) {
      _showSnack(e.toString(), FuturexColors.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPass.text != _confirmPass.text) {
      _showSnack('Passwords do not match', FuturexColors.error);
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider)
          .changePassword(_currentPass.text, _newPass.text);
      if (mounted) Navigator.pop(context);
      _showSnack('Password changed successfully', FuturexColors.success);
      _currentPass.clear();
      _newPass.clear();
      _confirmPass.clear();
    } catch (e) {
      _showSnack(e.toString(), FuturexColors.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Information', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(controller: _first, decoration: const InputDecoration(labelText: 'First name')),
            const SizedBox(height: 16),
            TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last name')),
            const SizedBox(height: 16),
            TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _saveProfile,
                child: const Text('Save changes'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showSecuritySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Security Settings', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(controller: _currentPass, obscureText: true, decoration: const InputDecoration(labelText: 'Current password')),
            const SizedBox(height: 16),
            TextField(controller: _newPass, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
            const SizedBox(height: 16),
            TextField(controller: _confirmPass, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm password')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _changePassword,
                child: const Text('Update password'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final avatar = resolveMediaUrl(user?.profileImage);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark || 
                  (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    // UI Colors based on exact design logic but adapting to dark mode
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FE),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: widget.bottomInset + 24),
        child: Column(
          children: [
            // Blue Header Section
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 32,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF534AEB), // Exact blue from the design
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!widget.embedded)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                      const Icon(Icons.more_vert_rounded, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                      child: avatar.isEmpty
                          ? const Icon(Icons.person_rounded, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'Student',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Premium Card Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          '${user?.firstName ?? "Student"}, join Runna Premium',
                          style: GoogleFonts.outfit(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Subscribe to unlock the rest of your weeks and reach your full potential',
                      style: GoogleFonts.plusJakartaSans(
                        color: subtextColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF534AEB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('SUBSCRIBE', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('RESTORE', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CONTENT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: subtextColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      onTap: _showEditProfileSheet,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'Security Settings',
                      onTap: _showSecuritySheet,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      title: 'Dark Mode',
                      trailing: CupertinoSwitch(
                        value: isDark,
                      activeTrackColor: const Color(0xFF534AEB),
                        onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                      ),
                      textColor: textColor,
                      subtextColor: subtextColor,
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notification Settings',
                      onTap: () {},
                      textColor: textColor,
                      subtextColor: subtextColor,
                      isDark: isDark,
                    ),
                    _buildDivider(isDark),
                    _buildMenuItem(
                      icon: Icons.people_outline_rounded,
                      title: 'Community Settings',
                      onTap: () {},
                      textColor: textColor,
                      subtextColor: subtextColor,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
      indent: 56,
      endIndent: 20,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    required Color textColor,
    required Color subtextColor,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: subtextColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null) 
                trailing
              else
                Icon(Icons.chevron_right_rounded, color: subtextColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
