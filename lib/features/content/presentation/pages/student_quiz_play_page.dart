import 'dart:async';
import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentQuizPlayPage extends StatefulWidget {
  const StudentQuizPlayPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.durationMinutes,
  });

  final String quizId;
  final String quizTitle;
  final int durationMinutes;

  @override
  State<StudentQuizPlayPage> createState() => _StudentQuizPlayPageState();
}

class _StudentQuizPlayPageState extends State<StudentQuizPlayPage> {
  bool _loading = true;
  List<dynamic> _problems = [];
  int _currentIndex = 0;
  final Map<String, int> _answers = {}; // {problemId: selectedOptionIndex}

  // Timer fields
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isTimed = false;

  // Quiz submission states
  bool _submitting = false;
  Map<String, dynamic>? _results; // Stores final results map

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      final data = await ContentRemoteDataSource().getQuiz(widget.quizId);
      final List<dynamic> list = (data is Map
              ? (data['problems'] ?? data['questions'] ?? [])
              : []) as List<dynamic>;

      setState(() {
        _problems = list;
        _loading = false;
        _isTimed = widget.durationMinutes > 0;
        if (_isTimed) {
          _secondsRemaining = widget.durationMinutes * 60;
          _startTimer();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load quiz: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        _submitQuiz(autoSubmit: true);
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    if (_submitting) return;
    _timer?.cancel();
    setState(() => _submitting = true);

    if (autoSubmit && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time is up! Submitting your answers...'),
          backgroundColor: FuturexColors.error,
        ),
      );
    }

    try {
      final answersPayload = _problems.map((p) {
        final pId = p['_id']?.toString() ?? p['id']?.toString() ?? '';
        return {
          'problemId': pId,
          'submittedAnswer': _answers[pId] ?? -1, // -1 means unanswered
        };
      }).toList();

      final res = await ContentRemoteDataSource().submitQuiz(widget.quizId, answersPayload);

      setState(() {
        _results = res is Map ? Map<String, dynamic>.from(res) : {'score': 0};
        _submitting = false;
      });
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    }
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: FuturexColors.scaffoldBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: FuturexColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const FuturexLoadingBody(message: 'Loading quiz questions...'),
      );
    }

    // If results are loaded, show the summary dashboard
    if (_results != null) {
      return _buildResultsDashboard();
    }

    if (_problems.isEmpty) {
      return Scaffold(
        backgroundColor: FuturexColors.scaffoldBg,
        appBar: AppBar(
          title: Text(widget.quizTitle),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'This quiz has no questions.',
            style: GoogleFonts.plusJakartaSans(color: FuturexColors.textSecondary),
          ),
        ),
      );
    }

    final currentProblem = _problems[_currentIndex] as Map;
    final currentProblemId = currentProblem['_id']?.toString() ?? currentProblem['id']?.toString() ?? '';
    final questionText = currentProblem['question']?.toString() ?? currentProblem['problemText']?.toString() ?? 'Question';
    final options = (currentProblem['options'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return Scaffold(
      backgroundColor: FuturexColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: FuturexColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: FuturexColors.textPrimary),
          onPressed: () {
            // Confirm quit
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Quit Quiz?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                content: const Text('Your progress in this quiz will be lost.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: const Text('Quit', style: TextStyle(color: FuturexColors.error, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(
          widget.quizTitle,
          style: GoogleFonts.outfit(
            color: FuturexColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isTimed)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _secondsRemaining < 60
                        ? FuturexColors.error.withValues(alpha: 0.1)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _secondsRemaining < 60
                          ? FuturexColors.error.withValues(alpha: 0.3)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: _secondsRemaining < 60 ? FuturexColors.error : FuturexColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(_secondsRemaining),
                        style: TextStyle(
                          color: _secondsRemaining < 60 ? FuturexColors.error : FuturexColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _problems.length,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              color: FuturexColors.primary,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FuturexContentCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question tracker badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: FuturexColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'QUESTION ${_currentIndex + 1} OF ${_problems.length}',
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: FuturexColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            '${((_currentIndex / _problems.length) * 100).toStringAsFixed(0)}% Completed',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: FuturexColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Question text
                      Text(
                        questionText,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: FuturexColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Options list
                      ...options.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final text = entry.value;
                        final isSelected = _answers[currentProblemId] == idx;
                        final char = String.fromCharCode(65 + idx);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _answers[currentProblemId] = idx;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? FuturexColors.primary.withValues(alpha: 0.05) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? FuturexColors.primary : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? FuturexColors.primary : const Color(0xFFF1F5F9),
                                    ),
                                    child: Text(
                                      char,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : FuturexColors.textSecondary,
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
                                        color: isSelected ? FuturexColors.primary : FuturexColors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom navigation controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: FuturexColors.surface,
                border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
              ),
              child: Row(
                children: [
                  // Previous button
                  if (_currentIndex > 0)
                    OutlinedButton(
                      onPressed: () {
                        setState(() => _currentIndex--);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: FuturexColors.textSecondary),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(width: 12),
                  // Next / Submit button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _submitting
                            ? null
                            : () {
                                if (_currentIndex < _problems.length - 1) {
                                  setState(() => _currentIndex++);
                                } else {
                                  // Submit confirmation
                                  _showSubmitConfirmation();
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: FuturexColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _currentIndex < _problems.length - 1 ? 'Next Question' : 'Finish Quiz',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14.5),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmitConfirmation() {
    final unanswered = _problems.length - _answers.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Submit Quiz?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          unanswered > 0
              ? 'You have $unanswered unanswered questions. Are you sure you want to submit?'
              : 'All questions answered! Ready to see your results?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Go back', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitQuiz();
            },
            child: const Text('Submit', style: TextStyle(color: FuturexColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsDashboard() {
    final score = _results?['score'] ?? 0;
    final total = _problems.length;
    final pct = total > 0 ? (score / total) * 100 : 0;
    final feedbackMsg = pct >= 80
        ? 'Excellent! You are fully prepared.'
        : pct >= 50
            ? 'Good effort! A bit more practice and you will master this.'
            : 'Keep reviewing the material and try again!';

    Color accentColor = FuturexColors.success;
    IconData accentIcon = Icons.stars_rounded;
    if (pct < 50) {
      accentColor = FuturexColors.error;
      accentIcon = Icons.sentiment_dissatisfied_rounded;
    } else if (pct < 80) {
      accentColor = Colors.orange;
      accentIcon = Icons.thumb_up_alt_rounded;
    }

    return Scaffold(
      backgroundColor: FuturexColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Big colored trophy/medal icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(accentIcon, color: accentColor, size: 72),
              ),
              const SizedBox(height: 24),
              Text(
                'Quiz Finished!',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: FuturexColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feedbackMsg,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  color: FuturexColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),
              // Score statistics card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Score',
                          style: GoogleFonts.plusJakartaSans(
                            color: FuturexColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$score / $total',
                          style: GoogleFonts.outfit(
                            color: FuturexColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 1.5, height: 40, color: const Color(0xFFE2E8F0)),
                    Column(
                      children: [
                        Text(
                          'Accuracy',
                          style: GoogleFonts.plusJakartaSans(
                            color: FuturexColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: GoogleFonts.outfit(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    // Retry quiz
                    setState(() {
                      _currentIndex = 0;
                      _answers.clear();
                      _results = null;
                      _loading = true;
                    });
                    _loadQuiz();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: FuturexColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Retry Quiz',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Text(
                    'Back to Topic',
                    style: GoogleFonts.plusJakartaSans(
                      color: FuturexColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
