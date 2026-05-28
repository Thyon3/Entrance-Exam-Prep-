import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/ai/presentation/pages/student_chat_page.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopicExamPage extends StatefulWidget {
  const TopicExamPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicExamPage> createState() => _TopicExamPageState();
}

class _TopicExamPageState extends State<TopicExamPage> {
  List<dynamic> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ContentRemoteDataSource().getExercises(widget.topicId);
      setState(() {
        _questions = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Intro banner card
        FuturexContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_rounded, color: Color(0xFF4527A0), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Exam Practice Sheet',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: FuturexColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Review standard exam questions for this topic. Use the interactive "Ask AI" button on any question to get a complete step-by-step breakdown.',
                style: GoogleFonts.plusJakartaSans(
                  color: FuturexColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        
        // Questions list
        ..._questions.asMap().entries.map((entry) {
          final idx = entry.key;
          final q = entry.value as Map;
          final questionText = q['question']?.toString() ?? '';

          return FuturexContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Badge Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4527A0).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'QUESTION ${idx + 1}',
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4527A0),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Exam Std',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: FuturexColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Question Content
                Text(
                  questionText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: FuturexColors.textPrimary,
                    height: 1.45,
                  ),
                ),
                
                // Ask AI Button (only for student role)
                if (widget.isStudent) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentChatPage(
                              topicId: widget.topicId,
                              prefilledPrompt: 'Explain this entrance exam question step-by-step: "$questionText"',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: FuturexColors.primary.withValues(alpha: 0.3)),
                        foregroundColor: FuturexColors.primary,
                      ),
                      icon: const Icon(Icons.smart_toy_outlined, size: 18),
                      label: Text(
                        'Ask AI to explain',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),

        if (_questions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No exam questions available yet.',
                style: GoogleFonts.plusJakartaSans(color: FuturexColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }
}
