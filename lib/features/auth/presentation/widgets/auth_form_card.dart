import 'package:finalyearproject/features/auth/presentation/theme/auth_theme.dart';
import 'package:finalyearproject/features/auth/presentation/widgets/auth_background.dart';
import 'package:flutter/material.dart';

/// White rounded card with watermark logo (nexatracker auth forms).
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.child,
    this.cardHeightFactor = 0.5,
    this.logoBottomFactor = 0.3,
  });

  final Widget child;
  final double cardHeightFactor;
  final double logoBottomFactor;

  static const String logoAsset = 'lib/assets/images/application_log.png';

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: height * logoBottomFactor,
            left: -width * 0.15,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                logoAsset,
                height: height * 0.3,
                width: width,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          SizedBox(
            height: height * cardHeightFactor,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Top spacing + title + card + footer used on login/forgot/reset flows.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.card,
    this.topSpacingFactor = 0.1,
    this.middleSpacingFactor = 0.15,
    this.showFooter = true,
    this.leading,
  });

  final String title;
  final Widget card;
  final double topSpacingFactor;
  final double middleSpacingFactor;
  final bool showFooter;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * topSpacingFactor),
              if (leading != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(alignment: Alignment.centerLeft, child: leading),
                ),
              Text(title, style: AuthTheme.titleOnBg(context), textAlign: TextAlign.center),
              SizedBox(height: height * middleSpacingFactor),
              card,
              SizedBox(height: height * 0.16),
              if (showFooter)
                Text(
                  '© ${DateTime.now().year} Entrance Exam Prep',
                  style: AuthTheme.footer(),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
