/// Helpers for YouTube URLs stored in the API (`watch?v=`, `youtu.be/`, embed).
class YoutubeUtils {
  YoutubeUtils._();

  static String? extractVideoId(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final raw = url.trim();

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      if (uri.host.contains('youtu.be')) {
        final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        if (id != null && id.isNotEmpty) return id;
      }
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;
      final segments = uri.pathSegments;
      if (segments.contains('embed') && segments.length > 1) {
        return segments[segments.indexOf('embed') + 1];
      }
      if (segments.contains('shorts') && segments.length > 1) {
        return segments[segments.indexOf('shorts') + 1];
      }
    }

    final watch = RegExp(r'[?&]v=([a-zA-Z0-9_-]{11})').firstMatch(raw);
    if (watch != null) return watch.group(1);

    final short = RegExp(r'youtu\.be/([a-zA-Z0-9_-]{11})').firstMatch(raw);
    if (short != null) return short.group(1);

    final embed = RegExp(r'embed/([a-zA-Z0-9_-]{11})').firstMatch(raw);
    if (embed != null) return embed.group(1);

    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(raw)) return raw;
    return null;
  }

  static bool isYoutubeUrl(String? url) => extractVideoId(url) != null;

  static String thumbnailUrl(String videoId, {bool hd = true}) {
    final quality = hd ? 'hqdefault' : 'mqdefault';
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }
}
