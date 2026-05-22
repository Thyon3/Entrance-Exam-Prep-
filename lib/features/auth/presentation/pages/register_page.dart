import 'package:finalyearproject/core/widgets/error_banner.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/features/auth/data/auth_remote_data_source.dart';
import 'package:finalyearproject/features/auth/presentation/pages/login_page.dart';
import 'package:finalyearproject/shared/widgets/role_home_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'student';
  String? _stream;
  String? _gradeLevel = '12';
  final List<TextEditingController> _otp =
      List.generate(6, (_) => TextEditingController());
  String? _pendingEmail;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _email, _password, _phone, ..._otp]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final remote = AuthRemoteDataSource();
      final result = await remote.register({
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
        'phoneNumber': _phone.text.trim(),
        'role': _role,
        if (_role == 'student') 'stream': _stream ?? 'Natural',
        if (_role == 'student') 'gradeLevel': _gradeLevel,
      });
      if (!mounted) return;
      if (result.verificationRequired == true) {
        setState(() {
          _pendingEmail = _email.text.trim();
          _step = 1;
          _loading = false;
        });
      } else {
        await saveAccessToken(result.token);
        ref.read(authProvider.notifier).setUser(result.user);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => RoleHomeRouter(user: result.user)),
          (_) => false,
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _verify() async {
    final code = _otp.map((c) => c.text).join();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await ref.read(authProvider.notifier).verifyEmail(_pendingEmail!, code);
    if (!mounted) return;
    if (ok) {
      final user = ref.read(authProvider).user!;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => RoleHomeRouter(user: user)),
        (_) => false,
      );
    } else {
      setState(() {
        _error = ref.read(authProvider).error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_step == 0 ? 'Register' : 'Verify Email')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _step == 0 ? _buildForm() : _buildOtp(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[ErrorBanner(message: _error!), const SizedBox(height: 12)],
          TextFormField(
            controller: _firstName,
            decoration: const InputDecoration(labelText: 'First name'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _lastName,
            decoration: const InputDecoration(labelText: 'Last name'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => v == null || !v.contains('@') ? 'Invalid email' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phone,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: const [
              DropdownMenuItem(value: 'student', child: Text('Student')),
              DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
            ],
            onChanged: (v) => setState(() => _role = v ?? 'student'),
          ),
          if (_role == 'student') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _stream,
              decoration: const InputDecoration(labelText: 'Stream'),
              items: const [
                DropdownMenuItem(value: 'Natural', child: Text('Natural')),
                DropdownMenuItem(value: 'Social', child: Text('Social')),
              ],
              onChanged: (v) => setState(() => _stream = v),
              validator: (v) => _role == 'student' && v == null ? 'Select stream' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _gradeLevel,
              decoration: const InputDecoration(labelText: 'Grade'),
              items: ['9', '10', '11', '12']
                  .map((g) => DropdownMenuItem(value: g, child: Text('Grade $g')))
                  .toList(),
              onChanged: (v) => setState(() => _gradeLevel = v),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _register,
            child: _loading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Continue'),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            child: const Text('Already have an account?'),
          ),
        ],
      ),
    );
  }

  Widget _buildOtp() {
    return Column(
      children: [
        if (_error != null) ...[ErrorBanner(message: _error!), const SizedBox(height: 12)],
        Text('Enter the code sent to $_pendingEmail'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (i) => SizedBox(
              width: 44,
              child: TextField(
                controller: _otp[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus();
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _verify,
          child: _loading
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Verify & Continue'),
        ),
      ],
    );
  }
}
