import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/auth/application/auth_provider.dart';
import 'package:finalyearproject/features/auth/presentation/pages/welcome_page.dart';
import 'package:finalyearproject/shared/widgets/role_home_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth.isBootstrapping) {
      return const Scaffold(body: LoadingView(message: 'Loading...'));
    }
    if (!auth.isAuthenticated) {
      return const WelcomePage();
    }
    return RoleHomeRouter(user: auth.user!);
  }
}
