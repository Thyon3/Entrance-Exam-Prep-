import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/admin/data/admin_remote_data_source.dart';
import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:flutter/material.dart';

class AdminCoursesPage extends StatefulWidget {
  const AdminCoursesPage({super.key});

  @override
  State<AdminCoursesPage> createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage> {
  List<SubjectModel> _subjects = [];
  bool _loading = true;
  final _name = TextEditingController();
  String _grade = '12';
  String _stream = 'Natural';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await CurriculumRemoteDataSource().getSubjects();
    setState(() {
      _subjects = list;
      _loading = false;
    });
  }

  Future<void> _create() async {
    await AdminRemoteDataSource().createSubject({
      'subjectName': _name.text.trim(),
      'gradeLevel': _grade,
      'stream': _stream,
    });
    _name.clear();
    _load();
  }

  Future<void> _delete(String id) async {
    await AdminRemoteDataSource().deleteSubject(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Subject name')),
        DropdownButtonFormField<String>(
          value: _grade,
          items: ['9', '10', '11', '12']
              .map((g) => DropdownMenuItem(value: g, child: Text('Grade $g')))
              .toList(),
          onChanged: (v) => setState(() => _grade = v ?? '12'),
        ),
        DropdownButtonFormField<String>(
          value: _stream,
          items: const [
            DropdownMenuItem(value: 'Natural', child: Text('Natural')),
            DropdownMenuItem(value: 'Social', child: Text('Social')),
          ],
          onChanged: (v) => setState(() => _stream = v ?? 'Natural'),
        ),
        ElevatedButton(onPressed: _create, child: const Text('Add subject')),
        const SizedBox(height: 16),
        ..._subjects.map(
          (s) => Card(
            child: ListTile(
              title: Text(s.subjectName),
              subtitle: Text('Grade ${s.gradeLevel} · ${s.stream ?? ''}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(s.id),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
