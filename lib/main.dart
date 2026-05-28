import 'package:finalyearproject/core/theme/app_theme.dart';
import 'package:finalyearproject/shared/providers/theme_provider.dart';
import 'package:finalyearproject/shared/widgets/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EntranceExamApp()));
}

class EntranceExamApp extends ConsumerWidget {
  const EntranceExamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Entrance Exam Prep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}
