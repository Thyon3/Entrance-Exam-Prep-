import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
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
    if (_loading) return const FuturexLoadingBody();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (widget.isStudent)
          FuturexContentCard(
            title: 'Ask a question',
            child: Column(
              children: [
                TextField(
                  controller: _askController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Type your question...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _ask, child: const Text('Post question')),
                ),
              ],
            ),
          ),
        ..._questions.map((q) {
          final m = q as Map;
          final qid = m['_id']?.toString() ?? '';
          return FuturexContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m['questionText']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                if (!widget.isStudent) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      labelText: 'Your answer',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  TextButton(onPressed: () => _answer(qid), child: const Text('Submit answer')),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
