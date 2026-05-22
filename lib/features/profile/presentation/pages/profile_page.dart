import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/data/auth_repository.dart';
import 'package:finalyearproject/features/auth/data/auth_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  String? _error;
  String? _success;

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
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final user = await AuthRepository(AuthRemoteDataSource()).updateProfile({
        'firstName': _first.text.trim(),
        'lastName': _last.text.trim(),
        'phoneNumber': _phone.text.trim(),
      });
      ref.read(authProvider.notifier).setUser(user);
      setState(() => _success = 'Profile updated successfully');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPass.text != _confirmPass.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await AuthRepository(AuthRemoteDataSource())
          .changePassword(_currentPass.text, _newPass.text);
      setState(() => _success = 'Password changed successfully');
      _currentPass.clear();
      _newPass.clear();
      _confirmPass.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _messageBanner() {
    if (_error != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FuturexColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FuturexColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: FuturexColors.error),
            const SizedBox(width: 10),
            Expanded(child: Text(_error!, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
    }
    if (_success != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FuturexColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FuturexColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: FuturexColors.success),
            const SizedBox(width: 10),
            Expanded(child: Text(_success!, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _profileHeader(String avatar, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [FuturexColors.gradientStart, FuturexColors.gradientEnd],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? const Icon(Icons.person_rounded, size: 44, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            user?.fullName ?? 'Student',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final user = ref.watch(authProvider).user;
    final avatar = resolveMediaUrl(user?.profileImage);

    return ListView(
      padding: EdgeInsets.only(bottom: widget.bottomInset + 16),
      children: [
        if (!widget.embedded) _profileHeader(avatar, user),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.embedded) ...[
                _profileHeader(avatar, user),
                const SizedBox(height: 16),
              ],
              _messageBanner(),
              FuturexContentCard(
                title: 'Personal information',
                child: Column(
                  children: [
                    TextField(
                      controller: _first,
                      decoration: const InputDecoration(labelText: 'First name'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _last,
                      decoration: const InputDecoration(labelText: 'Last name'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone number'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _saveProfile,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save changes'),
                      ),
                    ),
                  ],
                ),
              ),
              FuturexContentCard(
                title: 'Security',
                child: Column(
                  children: [
                    TextField(
                      controller: _currentPass,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Current password'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _newPass,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'New password'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _confirmPass,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Confirm password'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _loading ? null : _changePassword,
                        child: const Text('Update password'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(title: 'Profile', showNotificationIcon: false),
      body: _buildContent(),
    );
  }
}
