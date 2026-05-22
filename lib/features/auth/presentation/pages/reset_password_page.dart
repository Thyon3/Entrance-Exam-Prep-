import 'package:finalyearproject/features/auth/data/auth_remote_data_source.dart';
import 'package:finalyearproject/features/auth/presentation/pages/login_page.dart';
import 'package:finalyearproject/features/auth/presentation/theme/auth_theme.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.resetToken});
  final String resetToken;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (_password.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthRemoteDataSource()
          .resetPassword(widget.resetToken, _password.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
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
      title: 'Reset Password',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      card: AuthFormCard(
        cardHeightFactor: 0.48,
        logoBottomFactor: 0.22,
        child: Column(
          children: [
            SizedBox(height: height * 0.11),
            AuthTextField(
              label: 'New password',
              controller: _password,
              hint: 'Create password',
              obscureText: _obscure1,
              iconAsset: 'lib/assets/icons/asterisk.png',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscure1 ? Icons.visibility_off : Icons.visibility,
                  color: AuthTheme.darkBlue,
                ),
                onPressed: () => setState(() => _obscure1 = !_obscure1),
              ),
            ),
            SizedBox(height: height * 0.02),
            AuthTextField(
              label: 'Re-enter password',
              controller: _confirm,
              hint: 'Re-enter password',
              obscureText: _obscure2,
              iconAsset: 'lib/assets/icons/asterisk.png',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscure2 ? Icons.visibility_off : Icons.visibility,
                  color: AuthTheme.darkBlue,
                ),
                onPressed: () => setState(() => _obscure2 = !_obscure2),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
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
                    : const Text('Update password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
