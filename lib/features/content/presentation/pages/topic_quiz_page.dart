import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:finalyearproject/features/content/presentation/pages/student_quiz_play_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopicQuizPage extends StatefulWidget {
  const TopicQuizPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicQuizPage> createState() => _TopicQuizPageState();
}

class _TopicQuizPageState extends State<TopicQuizPage> {
  List<dynamic> _quizzes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ContentRemoteDataSource().getQuizzes(widget.topicId);
    setState(() {
      _quizzes = list;
      _loading = false;
    });
  }

  Future<void> _startQuizPlay(String id, String title, String durationStr) async {
    try {
      await ContentRemoteDataSource().startQuiz(id);
    } catch (_) {
      // Ignore start failure if already started or initialized
    }
    if (!mounted) return;
    final parsedDuration = int.tryParse(durationStr) ?? 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentQuizPlayPage(
          quizId: id,
          quizTitle: title,
          durationMinutes: parsedDuration,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();
    if (_quizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No quizzes available for this topic.',
            style: GoogleFonts.plusJakartaSans(
              color: FuturexColors.textSecondary,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quizzes.length,
      itemBuilder: (context, i) {
        final q = _quizzes[i] as Map;
        final id = q['_id']?.toString() ?? '';
        final title = q['title']?.toString() ?? 'Quiz';
        final duration = q['duration']?.toString() ?? '';

        return FuturexContentCard(
          child: Row(
            children: [
              // Styled quiz icon badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.quiz_rounded, color: Colors.orange, size: 28),
              ),
              const SizedBox(width: 16),
              // Quiz details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: FuturexColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: Colors.grey.shade400, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          duration.isEmpty ? 'Untimed Quiz' : '$duration min duration',
                          style: GoogleFonts.plusJakartaSans(
                            color: FuturexColors.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Play button
              if (widget.isStudent)
                FilledButton(
                  onPressed: () => _startQuizPlay(id, title, duration),
                  style: FilledButton.styleFrom(
                    backgroundColor: FuturexColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    'Start',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
