import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter/material.dart';

class TopicQaPage extends StatefulWidget {
  const TopicQaPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicQaPage> createState() => _TopicQaPageState();
}

class _TopicQaPageState extends State<TopicQaPage> {
  List<dynamic> _questions = [];
  final _askController = TextEditingController();
  final _answerController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await EngagementRemoteDataSource().getTopicQuestions(widget.topicId);
    setState(() {
      _questions = list;
      _loading = false;
    });
  }

  Future<void> _ask() async {
    if (_askController.text.trim().isEmpty) return;
    await EngagementRemoteDataSource().askQuestion({
      'topicId': widget.topicId,
      'questionText': _askController.text.trim(),
    });
    _askController.clear();
    _load();
  }

  Future<void> _answer(String questionId) async {
    if (_answerController.text.trim().isEmpty) return;
    await EngagementRemoteDataSource()
        .answerQuestion(questionId, _answerController.text.trim());
    _answerController.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.isStudent) ...[
          TextField(
            controller: _askController,
            decoration: const InputDecoration(labelText: 'Ask a question'),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _ask, child: const Text('Post question')),
          const SizedBox(height: 16),
        ],
        ..._questions.map((q) {
          final m = q as Map;
          final qid = m['_id']?.toString() ?? '';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m['questionText']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (!widget.isStudent) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _answerController,
                      decoration: const InputDecoration(labelText: 'Your answer'),
                    ),
                    TextButton(onPressed: () => _answer(qid), child: const Text('Submit answer')),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
