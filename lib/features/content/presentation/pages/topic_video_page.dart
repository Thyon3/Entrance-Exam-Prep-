import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TopicVideoPage extends StatefulWidget {
  const TopicVideoPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicVideoPage> createState() => _TopicVideoPageState();
}

class _TopicVideoPageState extends State<TopicVideoPage> {
  List<dynamic> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ContentRemoteDataSource().getVideos(widget.topicId);
    setState(() {
      _videos = list;
      _loading = false;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody(message: 'Loading videos...');
    if (_videos.isEmpty) {
      return const Center(child: Text('No videos yet.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _videos.length,
      itemBuilder: (context, i) {
        final v = _videos[i] as Map;
        final title = v['title']?.toString() ?? 'Video';
        final url = v['videoUrl']?.toString() ?? '';
        return FuturexContentCard(
          title: title,
          child: InkWell(
            onTap: url.isNotEmpty ? () => _openUrl(url) : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          url.isEmpty ? 'No URL' : 'Tap to watch',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
