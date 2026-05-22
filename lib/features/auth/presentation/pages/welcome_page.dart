import 'package:finalyearproject/features/auth/presentation/pages/login_page.dart';
import 'package:finalyearproject/features/auth/presentation/pages/register_page.dart';
import 'package:finalyearproject/features/auth/presentation/theme/auth_theme.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AuthTheme.bgGradientStart, AuthTheme.bgGradientEnd],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 100,
              left: -50,
              child: _BlurCircle(
                color: AuthTheme.neonGreen.withValues(alpha: 0.1),
                size: 300,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AuthTheme.neonGreen.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: AuthTheme.neonGreen,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Entrance Exam Prep',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Prepare for Grade 12 entrance exams with lessons, quizzes, and your AI study assistant.',
                      style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 3),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: ElevatedButton(
                        style: AuthTheme.welcomeFilledStyle(context),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        ),
                        child: const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: ElevatedButton(
                        style: AuthTheme.welcomeOutlinedStyle(context),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
