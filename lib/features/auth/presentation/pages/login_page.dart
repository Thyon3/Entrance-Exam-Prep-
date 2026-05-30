import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:finalyearproject/features/auth/presentation/pages/register_page.dart';
import 'package:finalyearproject/features/auth/presentation/theme/auth_theme.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:finalyearproject/shared/widgets/role_home_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).login(
          _email.text.trim(),
          _password.text,
        );
    if (!mounted) return;
    if (ok) {
      final user = ref.read(authProvider).user!;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => RoleHomeRouter(user: user)),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return AuthScaffold(
      title: 'Login to Account',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      card: AuthFormCard(
        child: Form(
          key: _formKey,
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
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Password',
                controller: _password,
                hint: '*******',
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
                validator: (v) =>
                    v == null || v.length < 6 ? 'Password required' : null,
              ),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AuthTheme.primaryButtonStyle(context),
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                ),
                child: Text(
                  'Forget Password',
                  style: AuthTheme.fieldLabel().copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
                child: Text(
                  'Create an account',
                  style: AuthTheme.fieldLabel().copyWith(
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    color: AuthTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
