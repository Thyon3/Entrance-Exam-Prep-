import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';

class TopicQuizPage extends StatefulWidget {
  const TopicQuizPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicQuizPage> createState() => _TopicQuizPageState();
}

class _TopicQuizPageState extends State<TopicQuizPage> {
  List<dynamic> _quizzes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ContentRemoteDataSource().getQuizzes(widget.topicId);
    setState(() {
      _quizzes = list;
      _loading = false;
    });
  }

  Future<void> _startQuiz(String quizId) async {
    try {
      await ContentRemoteDataSource().startQuiz(quizId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz started. Complete questions when ready.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _quizzes.length,
      itemBuilder: (context, i) {
        final q = _quizzes[i] as Map;
        final id = q['_id']?.toString() ?? '';
        final title = q['title']?.toString() ?? 'Quiz';
        final duration = q['duration']?.toString() ?? '';
        return FuturexContentCard(
          title: title,
          child: Row(
            children: [
              Icon(Icons.quiz_outlined, color: Colors.blue.shade700, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  duration.isEmpty ? 'Timed quiz' : '$duration min',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              if (widget.isStudent)
                ElevatedButton(
                  onPressed: () => _startQuiz(id),
                  child: const Text('Start'),
                ),
            ],
          ),
        );
      },
    );
  }
}
