import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
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
    if (_loading) return const FuturexLoadingBody(message: 'Loading notes...');
    if (_concepts.isEmpty) {
      return const FuturexEmptyState(
        title: 'No notes yet',
        message: 'Concept notes for this topic will appear here.',
        icon: Icons.article_outlined,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _concepts.length,
      itemBuilder: (context, i) {
        final c = _concepts[i] as Map;
        final title = c['title']?.toString() ?? 'Note';
        final body = c['content']?.toString() ?? '';
        final img = resolveMediaUrl(c['contentImage']?.toString());
        return FuturexContentCard(
          title: title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (img.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(img, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
              ],
              MarkdownBody(
                data: body.isEmpty ? '_No content_' : body,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
