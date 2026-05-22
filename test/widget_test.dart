import 'package:finalyearproject/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App loads welcome when logged out', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EntranceExamApp()));
    await tester.pumpAndSettle();
    expect(find.text('Entrance Exam Prep'), findsOneWidget);
  });
}
