import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const gradeItems = ['9', '10', '11', '12'];

class GradeNotifier extends StateNotifier<String> {
  GradeNotifier() : super('12') {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selectedGrade');
    if (saved != null && gradeItems.contains(saved)) state = saved;
  }

  Future<void> setGrade(String grade) async {
    state = grade;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGrade', grade);
  }
}

final selectedGradeProvider = StateNotifierProvider<GradeNotifier, String>(
  (ref) => GradeNotifier(),
);

bool gradeMatchesFilter(String? subjectGrade, String selectedGrade) {
  final g = (subjectGrade ?? '').replaceAll(RegExp(r'\D'), '');
  final s = selectedGrade.replaceAll(RegExp(r'\D'), '');
  if (g.isNotEmpty && s.isNotEmpty) return g == s;
  return subjectGrade == selectedGrade;
}
