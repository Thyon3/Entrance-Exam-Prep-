import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/utils/youtube_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// In-app YouTube player with speed, captions, quality info, and fullscreen.
class TopicVideoPlayerPage extends StatefulWidget {
  const TopicVideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
    this.topicName,
  });

  final String videoUrl;
  final String title;
  final String? topicName;

  @override
  State<TopicVideoPlayerPage> createState() => _TopicVideoPlayerPageState();
}

class _TopicVideoPlayerPageState extends State<TopicVideoPlayerPage> {
  late final YoutubePlayerController _controller;
  late final String? _videoId;
  bool _captionsOn = true;
  String _captionLanguage = 'en';
  double _playbackRate = 1.0;
  String _qualityLabel = 'Auto';
  bool _isFullscreen = false;
  bool _ready = false;

  static const _speedOptions = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  static const _captionLanguages = {
    'en': 'English',
    'am': 'Amharic',
    'ar': 'Arabic',
    'fr': 'French',
    'es': 'Spanish',
    'hi': 'Hindi',
  };

  YoutubePlayerParams get _playerParams => YoutubePlayerParams(
        enableCaption: _captionsOn,
        captionLanguage: _captionLanguage,
        showControls: false,
        showFullscreenButton: false,
        playsInline: true,
        strictRelatedVideos: true,
        origin: 'https://www.youtube-nocookie.com',
      );

  @override
  void initState() {
    super.initState();
    _videoId = YoutubeUtils.extractVideoId(widget.videoUrl);
    _controller = YoutubePlayerController(params: _playerParams);

    if (_videoId != null) {
      _controller.loadVideoById(videoId: _videoId);
    }

    _controller.listen((event) {
      if (!mounted) return;
      setState(() {
        _ready = event.playerState != PlayerState.unknown;
        if (event.playbackRate > 0) _playbackRate = event.playbackRate;
        final quality = event.playbackQuality;
        if (quality != null && quality.isNotEmpty) {
          _qualityLabel = _formatQuality(quality);
        }
      });
    });

    _controller.setFullScreenListener((isFullScreen) {
      _onFullscreenChanged(isFullScreen);
    });

    WakelockPlus.enable();
  }

  String _formatQuality(String raw) {
    if (raw.toLowerCase() == 'auto') return 'Auto';
    if (raw.contains('hd')) return 'HD';
    if (raw.contains('large')) return '480p';
    if (raw.contains('medium')) return '360p';
    if (raw.contains('small')) return '240p';
    return raw;
  }

  Future<void> _onFullscreenChanged(bool enter) async {
    setState(() => _isFullscreen = enter);
    if (enter) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _setSpeed(double rate) async {
    await _controller.setPlaybackRate(rate);
    setState(() => _playbackRate = rate);
  }

  Future<void> _reloadPlayer({bool keepPosition = false}) async {
    if (_videoId == null) return;
    double? at;
    if (keepPosition) {
      try {
        at = await _controller.currentTime;
      } catch (_) {}
    }
    await _controller.load(params: _playerParams);
    await _controller.loadVideoById(
      videoId: _videoId,
      startSeconds: at,
    );
  }

  Future<void> _toggleCaptions() async {
    setState(() => _captionsOn = !_captionsOn);
    await _reloadPlayer(keepPosition: true);
  }

  Future<void> _setCaptionLanguage(String code) async {
    setState(() {
      _captionLanguage = code;
      _captionsOn = true;
    });
    await _reloadPlayer(keepPosition: true);
  }

  void _showSpeedSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: FuturexColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Playback speed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            ..._speedOptions.map((s) {
              final selected = (_playbackRate - s).abs() < 0.01;
              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? FuturexColors.primary : Colors.grey,
                ),
                title: Text(s == 1.0 ? 'Normal' : '${s}x'),
                onTap: () {
                  Navigator.pop(ctx);
                  _setSpeed(s);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCaptionSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: FuturexColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Subtitles', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Show closed captions when available'),
              value: _captionsOn,
              onChanged: (v) {
                Navigator.pop(ctx);
                if (v != _captionsOn) _toggleCaptions();
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Caption language',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
            ..._captionLanguages.entries.map((e) {
              return ListTile(
                title: Text(e.value),
                trailing: _captionLanguage == e.key
                    ? const Icon(Icons.check, color: FuturexColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  _setCaptionLanguage(e.key);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showQualitySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: FuturexColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Video quality',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Current: $_qualityLabel',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: FuturexColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'YouTube adjusts quality automatically based on your connection '
                '(same as the YouTube app). Manual quality selection is limited '
                'on mobile players.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: FuturexColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: FuturexColors.primary, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubeUtils.extractVideoId(widget.videoUrl);

    if (videoId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Text('Invalid or missing YouTube video URL.'),
        ),
      );
    }

    return YoutubePlayerScaffold(
      controller: _controller,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _isFullscreen
              ? null
              : AppBar(
                  title: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
          body: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    player,
                    if (!_ready)
                      const ColoredBox(
                        color: Colors.black,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              if (!_isFullscreen)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: FuturexColors.scaffoldBg,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: FuturexColors.textPrimary,
                          ),
                        ),
                        if (widget.topicName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.topicName!,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _controlButton(
                              icon: Icons.speed_rounded,
                              label: _playbackRate == 1.0
                                  ? 'Speed'
                                  : '${_playbackRate}x',
                              onTap: _showSpeedSheet,
                            ),
                            const SizedBox(width: 8),
                            _controlButton(
                              icon: _captionsOn
                                  ? Icons.closed_caption_rounded
                                  : Icons.closed_caption_disabled_rounded,
                              label: 'Subtitles',
                              onTap: _showCaptionSheet,
                            ),
                            const SizedBox(width: 8),
                            _controlButton(
                              icon: Icons.hd_rounded,
                              label: _qualityLabel,
                              onTap: _showQualitySheet,
                            ),
                            const SizedBox(width: 8),
                            _controlButton(
                              icon: Icons.screen_rotation_rounded,
                              label: 'Fullscreen',
                              onTap: () => _controller.toggleFullScreen(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: FuturexColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: Colors.grey.shade600, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tip: Use speed and subtitles below the player. '
                                  'Rotate your device or tap Fullscreen for landscape.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
