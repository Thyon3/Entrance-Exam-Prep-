// Personal Information Page
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/shared/providers/theme_provider.dart';

class PersonalInformationPage extends ConsumerStatefulWidget {
  const PersonalInformationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends ConsumerState<PersonalInformationPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authProvider).user;
    if (u != null) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Personal Information',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title removed from body as it's in AppBar
              const SizedBox(height: 24),
              TextField(controller: _first, decoration: const InputDecoration(labelText: 'First name'), style: TextStyle(color: textColor)),
              const SizedBox(height: 16),
              TextField(controller: _last, decoration: const InputDecoration(labelText: 'Last name'), style: TextStyle(color: textColor)),
              const SizedBox(height: 16),
              TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number'), style: TextStyle(color: textColor)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _saveProfile,
                  child: const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
