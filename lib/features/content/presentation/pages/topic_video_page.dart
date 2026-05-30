import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/utils/youtube_utils.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  Map? _selectedVideo;
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ContentRemoteDataSource().getVideos(widget.topicId);
      setState(() {
        _videos = list;
        _loading = false;
        if (_videos.isNotEmpty) {
          final firstVideo = _videos.first as Map;
          final videoUrl = firstVideo['videoUrl']?.toString() ?? '';
          final videoId = YoutubeUtils.extractVideoId(videoUrl);
          if (videoId != null) {
            _selectedVideo = firstVideo;
            _controller = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
                disableDragSeek: false,
                loop: false,
                isLive: false,
                forceHD: false,
                enableCaption: true,
              ),
            );
          }
        }
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _playVideo(Map v) {
    final videoUrl = v['videoUrl']?.toString() ?? '';
    final videoId = YoutubeUtils.extractVideoId(videoUrl);

    if (videoId == null) {
      if (videoUrl.isNotEmpty) {
        launchUrl(Uri.parse(videoUrl), mode: LaunchMode.externalApplication);
      }
      return;
    }

    setState(() {
      _selectedVideo = v;
    });

    if (_controller == null) {
      setState(() {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
          ),
        );
      });
    } else {
      _controller!.load(videoId);
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

    if (_controller == null) {
      return RefreshIndicator(
        onRefresh: _load,
        color: FuturexColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _videos.length,
          itemBuilder: (context, index) {
            final v = _videos[index] as Map;
            return _buildVideoRow(v, index);
          },
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: FuturexColors.primary,
      ),
      builder: (context, player) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Persistent Player Card at the top
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: player,
                ),
              ),
            ),
            // Currently playing detail
            if (_selectedVideo != null) _buildCurrentlyPlayingHeader(),
            Divider(height: 1, color: dividerColor),
            // List of videos
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                color: FuturexColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _videos.length,
                  itemBuilder: (context, index) {
                    final v = _videos[index] as Map;
                    return _buildVideoRow(v, index);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentlyPlayingHeader() {
    final title = _selectedVideo?['title']?.toString() ?? 'Selected Lesson';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: FuturexColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: FuturexColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CURRENTLY PLAYING',
                      style: GoogleFonts.plusJakartaSans(
                        color: FuturexColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoRow(Map v, int index) {
    final title = v['title']?.toString() ?? 'Untitled Lesson';
    final url = v['videoUrl']?.toString() ?? '';
    final videoId = YoutubeUtils.extractVideoId(url);
    final isYoutube = videoId != null;
    final isSelected = _selectedVideo == v;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? (isSelected ? FuturexColors.primary.withValues(alpha: 0.12) : const Color(0xFF1E293B))
        : (isSelected ? FuturexColors.primary.withValues(alpha: 0.05) : Colors.white);
    final borderColor = isSelected
        ? FuturexColors.primary
        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06));
    final thumbBg = isDark ? const Color(0xFF334155) : Colors.grey.shade200;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF475569);
    final chevronColor = isSelected
        ? FuturexColors.primary
        : (isDark ? Colors.white30 : Colors.grey.shade400);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? FuturexColors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: isDark ? 0.18 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _playVideo(v),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: thumbBg,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: videoId != null
                              ? Image.network(
                                  YoutubeUtils.thumbnailUrl(videoId),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _thumbFallback(small: true),
                                )
                              : _thumbFallback(small: true),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? FuturexColors.primary.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            isSelected ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: isSelected ? 20 : 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 14,
                            color: isSelected ? FuturexColors.primary : textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isYoutube ? Icons.smart_display_rounded : Icons.open_in_new_rounded,
                              size: 14,
                              color: isSelected
                                  ? FuturexColors.primary.withValues(alpha: 0.7)
                                  : textSecondary.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isYoutube ? 'In-app Player' : 'External Link',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? FuturexColors.primary.withValues(alpha: 0.7)
                                    : textSecondary.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: chevronColor, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _thumbFallback({bool small = false}) {
    return Container(
      color: FuturexColors.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.movie_rounded,
        size: small ? 24 : 48,
        color: FuturexColors.primary,
      ),
    );
  }
}
