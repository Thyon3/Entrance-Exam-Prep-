import 'package:finalyearproject/core/widgets/loading_view.dart';
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
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videos.length,
      itemBuilder: (context, i) {
        final v = _videos[i] as Map;
        final title = v['title']?.toString() ?? 'Video';
        final url = v['videoUrl']?.toString() ?? '';
        return Card(
          child: ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: Text(title),
            subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: url.isNotEmpty ? () => _openUrl(url) : null,
          ),
        );
      },
    );
  }
}
