import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_detail_shell_page.dart';
import 'package:flutter/material.dart';

class TopicSearchPage extends StatefulWidget {
  const TopicSearchPage({super.key});

  @override
  State<TopicSearchPage> createState() => _TopicSearchPageState();
}

class _TopicSearchPageState extends State<TopicSearchPage> {
  final _query = TextEditingController();
  List<TopicModel> _results = [];
  bool _searching = false;

  Future<void> _search() async {
    if (_query.text.trim().length < 2) return;
    setState(() => _searching = true);
    try {
      final list = await CurriculumRemoteDataSource().searchTopics(_query.text.trim());
      setState(() {
        _results = list;
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search topics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _query,
                    decoration: const InputDecoration(hintText: 'Search...'),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(onPressed: _search, icon: const Icon(Icons.search)),
              ],
            ),
          ),
          if (_searching) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final t = _results[i];
                return ListTile(
                  title: Text(t.topicName),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TopicDetailShellPage(
                        topicId: t.id,
                        topicName: t.topicName,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
