import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';

class TopicExamPage extends StatefulWidget {
  const TopicExamPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicExamPage> createState() => _TopicExamPageState();
}

class _TopicExamPageState extends State<TopicExamPage> {
  List<dynamic> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Topic-level exam practice uses generic question search when no paper linked
    try {
      final data = await ContentRemoteDataSource().getExercises(widget.topicId);
      setState(() {
        _questions = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Practice questions for this topic (exam-style MCQs).'),
        const SizedBox(height: 12),
        ..._questions.map((q) {
          final m = q as Map;
          return Card(
            child: ListTile(
              title: Text(m['question']?.toString() ?? 'Question'),
              subtitle: const Text('Tap exercise tab for interactive answers'),
            ),
          );
        }),
        if (_questions.isEmpty) const Text('No exam questions available yet.'),
      ],
    );
  }
}
