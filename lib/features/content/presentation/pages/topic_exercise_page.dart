import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopicExercisePage extends StatefulWidget {
  const TopicExercisePage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicExercisePage> createState() => _TopicExercisePageState();
}

class _TopicExercisePageState extends State<TopicExercisePage> {
  List<dynamic> _exercises = [];
  bool _loading = true;
  final Map<String, int> _selected = {};
  final Map<String, Map<String, dynamic>?> _feedback = {}; // {exerciseId: {'isCorrect': bool, 'correctIndex': int, 'message': String}}

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ContentRemoteDataSource().getExercises(widget.topicId);
    setState(() {
      _exercises = list;
      _loading = false;
    });
  }

  Future<void> _submit(String exerciseId, List<String> options) async {
    final answer = _selected[exerciseId];
    if (answer == null) return;
    try {
      final res = await ContentRemoteDataSource()
          .submitExercise(exerciseId, answer);
      
      final isCorrect = res is Map && res['isCorrect'] == true;
      int? correctIdx;
      
      if (res is Map && res['correctAnswer'] != null) {
        final rawCorrect = res['correctAnswer'].toString();
        final parsed = int.tryParse(rawCorrect);
        if (parsed != null && parsed >= 0 && parsed < options.length) {
          correctIdx = parsed;
        } else {
          final matchIdx = options.indexWhere((opt) => opt.trim().toLowerCase() == rawCorrect.trim().toLowerCase());
          if (matchIdx != -1) {
            correctIdx = matchIdx;
          }
        }
      }

      setState(() {
        _feedback[exerciseId] = {
          'isCorrect': isCorrect,
          'correctIndex': correctIdx,
          'message': isCorrect
              ? 'Excellent! Correct answer.'
              : 'Incorrect. The correct answer is: ${correctIdx != null ? options[correctIdx] : (res is Map ? res['correctAnswer'] ?? '' : '')}',
        };
      });
    } catch (e) {
      setState(() {
        _feedback[exerciseId] = {
          'isCorrect': false,
          'correctIndex': null,
          'message': e.toString(),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();
    if (_exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No practice exercises available for this topic.',
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
      itemCount: _exercises.length,
      itemBuilder: (context, i) {
        final ex = _exercises[i] as Map;
        final id = ex['_id']?.toString() ?? '';
        final question = ex['question']?.toString() ?? 'Question';
        final options =
            (ex['options'] as List?)?.map((e) => e.toString()).toList() ?? [];

        final feedback = _feedback[id];
        final isSubmitted = feedback != null;
        final isCorrect = feedback?['isCorrect'] == true;
        final correctIndex = feedback?['correctIndex'] as int?;

        return FuturexContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FuturexColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'QUESTION ${i + 1}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: FuturexColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Question text
              Text(
                question,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: FuturexColors.textPrimary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              // Options list
              ...options.asMap().entries.map((entry) {
                final idx = entry.key;
                final text = entry.value;
                final isSelected = _selected[id] == idx;
                
                // Styling logic for choices
                Color borderCol = const Color(0xFFE2E8F0);
                Color bgCol = Colors.white;
                Color textCol = FuturexColors.textPrimary;
                Widget? trailingIcon;

                if (isSubmitted) {
                  if (idx == correctIndex || (isCorrect && isSelected)) {
                    borderCol = FuturexColors.success;
                    bgCol = FuturexColors.success.withValues(alpha: 0.08);
                    textCol = FuturexColors.success;
                    trailingIcon = const Icon(Icons.check_circle_rounded, color: FuturexColors.success, size: 20);
                  } else if (isSelected && !isCorrect) {
                    borderCol = FuturexColors.error;
                    bgCol = FuturexColors.error.withValues(alpha: 0.08);
                    textCol = FuturexColors.error;
                    trailingIcon = const Icon(Icons.cancel_rounded, color: FuturexColors.error, size: 20);
                  }
                } else if (isSelected) {
                  borderCol = FuturexColors.primary;
                  bgCol = FuturexColors.primary.withValues(alpha: 0.05);
                  textCol = FuturexColors.primary;
                }

                final letter = String.fromCharCode(65 + idx); // A, B, C, D...

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.isStudent && !isSubmitted
                          ? () => setState(() => _selected[id] = idx)
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: bgCol,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderCol, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected || (isSubmitted && (idx == correctIndex || (isSelected && !isCorrect)))
                                    ? borderCol
                                    : const Color(0xFFF1F5F9),
                              ),
                              child: Text(
                                letter,
                                style: TextStyle(
                                  color: isSelected || (isSubmitted && (idx == correctIndex || (isSelected && !isCorrect)))
                                      ? Colors.white
                                      : FuturexColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                text,
                                style: GoogleFonts.plusJakartaSans(
                                  color: textCol,
                                  fontWeight: isSelected || (isSubmitted && idx == correctIndex)
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 14.5,
                                ),
                              ),
                            ),
                            if (trailingIcon != null) trailingIcon,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              // Action buttons & feedback
              if (widget.isStudent) ...[
                const SizedBox(height: 16),
                if (!isSubmitted)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _selected[id] != null
                          ? () => _submit(id, options)
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: FuturexColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Submit Answer',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                if (isSubmitted) ...[
                  const SizedBox(height: 12),
                  // Styled feedback box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? FuturexColors.success.withValues(alpha: 0.08)
                          : FuturexColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCorrect
                            ? FuturexColors.success.withValues(alpha: 0.15)
                            : FuturexColors.error.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          color: isCorrect ? FuturexColors.success : FuturexColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feedback['message'] ?? '',
                            style: GoogleFonts.plusJakartaSans(
                              color: isCorrect ? FuturexColors.success : FuturexColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
