import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/constants/util.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF475569);
    final imgFallbackBg = isDark ? const Color(0xFF334155) : Colors.grey.shade100;
    final imgFallbackIcon = isDark ? Colors.white30 : Colors.grey.shade400;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _concepts.length,
      itemBuilder: (context, i) {
        final c = _concepts[i] as Map;
        final title = c['title']?.toString() ?? 'Note';
        final body = c['content']?.toString() ?? '';
        final img = resolveMediaUrl(c['contentImage']?.toString());

        // Calculate reading time
        final words = body.split(RegExp(r'\s+')).length;
        final readingTime = (words / 200).ceil().clamp(1, 45);

        return FuturexContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: FuturexColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: FuturexColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '$readingTime min read',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: FuturexColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (img.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    img,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: imgFallbackBg,
                      alignment: Alignment.center,
                      child: Icon(Icons.broken_image_outlined, color: imgFallbackIcon, size: 36),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              MarkdownBody(
                data: body.isEmpty ? '_No content available._' : body,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    height: 1.6,
                    color: textSecondary,
                  ),
                  h1: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                  h2: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                  h3: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                  strong: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
                  em: const TextStyle(fontStyle: FontStyle.italic),
                  listBullet: TextStyle(color: textSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
