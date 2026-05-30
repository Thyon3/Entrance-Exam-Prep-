import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/presentation/theme/auth_theme.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(_email.text.trim());
      setState(() => _success = 'Check your email for reset instructions.');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return AuthScaffold(
      title: 'Forgot Password',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      card: AuthFormCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            AuthTextField(
              label: 'Email',
              controller: _email,
              hint: 'Email address',
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email_outlined,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_success != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _success!,
                  style: const TextStyle(color: AuthTheme.green),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: height * 0.03),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AuthTheme.primaryButtonStyle(context),
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Send reset link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
