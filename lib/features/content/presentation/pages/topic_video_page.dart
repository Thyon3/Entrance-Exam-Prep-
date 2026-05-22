import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/utils/youtube_utils.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:finalyearproject/features/content/presentation/pages/topic_video_player_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TopicVideoPage extends StatefulWidget {
  const TopicVideoPage({
    super.key,
    required this.topicId,
    this.isStudent = true,
    this.topicName,
  });

  final String topicId;
  final bool isStudent;
  final String? topicName;

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
    setState(() => _loading = true);
    try {
      final list = await ContentRemoteDataSource().getVideos(widget.topicId);
      setState(() {
        _videos = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _openVideo(Map v) async {
    final title = v['title']?.toString() ?? 'Video';
    final url = v['videoUrl']?.toString() ?? '';
    if (url.isEmpty) return;

    if (YoutubeUtils.isYoutubeUrl(url)) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => TopicVideoPlayerPage(
            videoUrl: url,
            title: title,
            topicName: widget.topicName,
          ),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const FuturexLoadingBody(message: 'Loading videos...');
    }

    if (_videos.isEmpty) {
      return const FuturexEmptyState(
        title: 'No videos yet',
        message: 'Video lessons for this topic will appear here.',
        icon: Icons.videocam_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: FuturexColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _videos.length,
        itemBuilder: (context, i) {
          final v = _videos[i] as Map;
          final title = v['title']?.toString() ?? 'Video';
          final url = v['videoUrl']?.toString() ?? '';
          final videoId = YoutubeUtils.extractVideoId(url);
          final isYoutube = videoId != null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Material(
              color: FuturexColors.surface,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: url.isNotEmpty ? () => _openVideo(v) : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: videoId != null
                              ? Image.network(
                                  YoutubeUtils.thumbnailUrl(videoId),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _thumbFallback(),
                                )
                              : _thumbFallback(),
                        ),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        if (isYoutube)
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'In-app player',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isYoutube
                                      ? 'Speed · subtitles · fullscreen'
                                      : 'Opens externally',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: FuturexColors.primary,
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
      ),
    );
  }

  Widget _thumbFallback() {
    return Container(
      color: FuturexColors.primary.withValues(alpha: 0.15),
      child: const Icon(
        Icons.movie_rounded,
        size: 48,
        color: FuturexColors.primary,
      ),
    );
  }
}
