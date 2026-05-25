import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/utils/youtube_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  YoutubePlayerController? _controller;
  late final String? _videoId;
  double _playbackRate = 1.0;
  bool _isFullscreen = false;

  static const _speedOptions = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();
    _videoId = YoutubeUtils.extractVideoId(widget.videoUrl);

    if (_videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          forceHD: false,
          controlsVisibleAtStart: true,
        ),
      );
    }

    WakelockPlus.enable();
  }

  Future<void> _setSpeed(double rate) async {
    _controller?.setPlaybackRate(rate);
    setState(() => _playbackRate = rate);
  }

  Future<void> _toggleFullscreen() async {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null || _controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Text('Invalid or missing YouTube video URL.'),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: FuturexColors.primary,
      ),
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        setState(() => _isFullscreen = false);
      },
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        setState(() => _isFullscreen = true);
      },
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
              // Player
              player,
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
                              icon: Icons.hd_rounded,
                              label: 'Quality',
                              onTap: _showQualitySheet,
                            ),
                            const SizedBox(width: 8),
                            _controlButton(
                              icon: Icons.screen_rotation_rounded,
                              label: 'Fullscreen',
                              onTap: _toggleFullscreen,
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
                                  'Tip: Use speed controls below the player. '
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
