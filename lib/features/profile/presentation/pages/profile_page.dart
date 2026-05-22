import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/data/auth_repository.dart';
import 'package:finalyearproject/features/auth/data/auth_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

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
    });
    try {
      final user = await AuthRepository(AuthRemoteDataSource()).updateProfile({
        'firstName': _first.text.trim(),
        'lastName': _last.text.trim(),
        'phoneNumber': _phone.text.trim(),
      });
      ref.read(authProvider.notifier).setUser(user);
      setState(() => _success = 'Profile updated');
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
    });
    try {
      await AuthRepository(AuthRemoteDataSource())
          .changePassword(_currentPass.text, _newPass.text);
      setState(() => _success = 'Password changed');
      _currentPass.clear();
      _newPass.clear();
      _confirmPass.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        filled: true,
        fillColor: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final avatar = resolveMediaUrl(user?.profileImage);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const GradientAppBar(title: 'Profile', showNotificationIcon: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            FuturexContentCard(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_success != null)
            FuturexContentCard(
              child: Text(_success!, style: const TextStyle(color: Colors.green)),
            ),
          FuturexContentCard(
            title: 'Account',
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                  child: avatar.isEmpty ? const Icon(Icons.person, size: 40) : null,
                ),
                const SizedBox(height: 8),
                Text(user?.email ?? '', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 16),
                TextField(controller: _first, decoration: _dec('First name')),
                const SizedBox(height: 12),
                TextField(controller: _last, decoration: _dec('Last name')),
                const SizedBox(height: 12),
                TextField(controller: _phone, decoration: _dec('Phone')),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveProfile,
                    child: const Text('Save profile'),
                  ),
                ),
              ],
            ),
          ),
          FuturexContentCard(
            title: 'Change password',
            child: Column(
              children: [
                TextField(controller: _currentPass, obscureText: true, decoration: _dec('Current')),
                const SizedBox(height: 12),
                TextField(controller: _newPass, obscureText: true, decoration: _dec('New')),
                const SizedBox(height: 12),
                TextField(controller: _confirmPass, obscureText: true, decoration: _dec('Confirm')),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _changePassword,
                    child: const Text('Update password'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
