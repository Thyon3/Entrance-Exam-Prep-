import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/data/auth_remote_data_source.dart';
import 'package:finalyearproject/features/auth/presentation/pages/login_page.dart';
import 'package:finalyearproject/features/auth/presentation/theme/auth_theme.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_otp_input.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_text_field.dart';
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
  String? _stream = 'Natural';
  String? _gradeLevel = '12';
  final List<TextEditingController> _otp =
      List.generate(6, (_) => TextEditingController());
  String? _pendingEmail;
  bool _loading = false;
  String? _error;
  bool _obscure = true;

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
    final height = MediaQuery.of(context).size.height;
    final title = _step == 0 ? 'Create Account' : 'Verify Email';

    return AuthScaffold(
      title: title,
      middleSpacingFactor: _step == 0 ? 0.08 : 0.12,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () {
          if (_step == 1) {
            setState(() => _step = 0);
          } else {
            Navigator.maybePop(context);
          }
        },
      ),
      card: AuthFormCard(
        cardHeightFactor: _step == 0 ? 0.72 : 0.38,
        logoBottomFactor: _step == 0 ? 0.45 : 0.08,
        child: _step == 0 ? _buildForm(height) : _buildOtp(height),
      ),
    );
  }

  Widget _buildForm(double height) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: height * 0.06),
            AuthTextField(
              label: 'First name',
              controller: _firstName,
              icon: Icons.person_outline,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            AuthTextField(
              label: 'Last name',
              controller: _lastName,
              icon: Icons.person_outline,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            AuthTextField(
              label: 'Email',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
              validator: (v) => v == null || !v.contains('@') ? 'Invalid email' : null,
            ),
            const SizedBox(height: 10),
            AuthTextField(
              label: 'Password',
              controller: _password,
              obscureText: _obscure,
              iconAsset: 'lib/assets/icons/asterisk.png',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AuthTheme.darkBlue,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 10),
            AuthTextField(
              label: 'Phone (optional)',
              controller: _phone,
              keyboardType: TextInputType.phone,
              iconAsset: 'lib/assets/icons/phone.png',
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 10),
            AuthDropdownField<String>(
              label: 'Role',
              value: _role,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'student'),
            ),
            if (_role == 'student') ...[
              const SizedBox(height: 10),
              AuthDropdownField<String>(
                label: 'Stream',
                value: _stream,
                items: const [
                  DropdownMenuItem(value: 'Natural', child: Text('Natural')),
                  DropdownMenuItem(value: 'Social', child: Text('Social')),
                ],
                onChanged: (v) => setState(() => _stream = v),
              ),
              const SizedBox(height: 10),
              AuthDropdownField<String>(
                label: 'Grade',
                value: _gradeLevel,
                items: ['9', '10', '11', '12']
                    .map((g) => DropdownMenuItem(value: g, child: Text('Grade $g')))
                    .toList(),
                onChanged: (v) => setState(() => _gradeLevel = v),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AuthTheme.primaryButtonStyle(context),
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Continue'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              child: Text(
                'Already have an account?',
                style: AuthTheme.fieldLabel().copyWith(
                  color: AuthTheme.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOtp(double height) {
    return Column(
      children: [
        SizedBox(height: height * 0.08),
        Text(
          'We sent a verification code to',
          style: AuthTheme.fieldLabel(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          _pendingEmail ?? '',
          style: AuthTheme.fieldLabel().copyWith(
            fontWeight: FontWeight.w700,
            color: AuthTheme.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        AuthOtpInput(controllers: _otp),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AuthTheme.primaryButtonStyle(context),
            onPressed: _loading ? null : _verify,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Verify & Continue'),
          ),
        ),
      ],
    );
  }
}
