import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TopicConceptPage extends StatefulWidget {
  const TopicConceptPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicConceptPage> createState() => _TopicConceptPageState();
}

class _TopicConceptPageState extends State<TopicConceptPage> {
  List<dynamic> _concepts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ContentRemoteDataSource().getConcepts(widget.topicId);
    setState(() {
      _concepts = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _concepts.length,
      itemBuilder: (context, i) {
        final c = _concepts[i] as Map;
        final title = c['title']?.toString() ?? 'Concept';
        final body = c['content']?.toString() ?? '';
        final img = resolveMediaUrl(c['contentImage']?.toString());
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (img.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Image.network(img, fit: BoxFit.cover),
                ],
                const SizedBox(height: 8),
                MarkdownBody(data: body.isEmpty ? '_No content_' : body),
              ],
            ),
          ),
        );
      },
    );
  }
}
