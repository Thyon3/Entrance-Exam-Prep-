import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
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
    if (_loading) return const FuturexLoadingBody();
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        FuturexContentCard(
          title: 'Exam practice',
          child: Text(
            'Practice questions for this topic. Use the Exercise tab for interactive answers.',
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ),
        ..._questions.map((q) {
          final m = q as Map;
          return FuturexContentCard(
            title: 'Question',
            child: Text(m['question']?.toString() ?? '', style: const TextStyle(fontSize: 15)),
          );
        }),
        if (_questions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No exam questions available yet.')),
          ),
      ],
    );
  }
}
