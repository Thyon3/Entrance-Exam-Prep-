import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:flutter/material.dart';

class TopicObjectivesPage extends StatefulWidget {
  const TopicObjectivesPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicObjectivesPage> createState() => _TopicObjectivesPageState();
}

class _TopicObjectivesPageState extends State<TopicObjectivesPage> {
  List<String> _objectives = [];
  final _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final topic = await CurriculumRemoteDataSource().getTopic(widget.topicId);
    setState(() {
      _objectives = topic.objectives ?? [];
      _loading = false;
    });
  }

  Future<void> _save() async {
    final lines = _controller.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    await CurriculumRemoteDataSource().updateTopic(widget.topicId, {
      'topicObjectives': lines,
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    if (!widget.isStudent) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller..text = _objectives.join('\n'),
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Objectives (one per line)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _save, child: const Text('Save objectives')),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _objectives.isEmpty
          ? [const Text('No objectives listed yet.')]
          : _objectives
              .map((o) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(o),
                    ),
                  ))
              .toList(),
    );
  }
}
