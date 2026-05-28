import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopicQaPage extends StatefulWidget {
  const TopicQaPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicQaPage> createState() => _TopicQaPageState();
}

class _TopicQaPageState extends State<TopicQaPage> {
  List<dynamic> _questions = [];
  final _askController = TextEditingController();
  final Map<String, TextEditingController> _answerControllers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _askController.dispose();
    for (final controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getAnswerController(String qid) {
    return _answerControllers.putIfAbsent(qid, () => TextEditingController());
  }

  Future<void> _load() async {
    final list = await EngagementRemoteDataSource().getTopicQuestions(widget.topicId);
    setState(() {
      _questions = list;
      _loading = false;
    });
  }

  Future<void> _ask() async {
    final text = _askController.text.trim();
    if (text.isEmpty) return;
    await EngagementRemoteDataSource().askQuestion({
      'topicId': widget.topicId,
      'questionText': text,
    });
    _askController.clear();
    _load();
  }

  Future<void> _answer(String questionId) async {
    final controller = _getAnswerController(questionId);
    final text = controller.text.trim();
    if (text.isEmpty) return;
    await EngagementRemoteDataSource().answerQuestion(questionId, text);
    controller.clear();
    _load();
  }

  Color _getAvatarColor(String username) {
    final h = username.hashCode.abs();
    final colors = [
      const Color(0xFF3F51B5),
      const Color(0xFF009688),
      const Color(0xFF673AB7),
      const Color(0xFFE91E63),
      const Color(0xFF4CAF50),
      const Color(0xFF03A9F4),
      const Color(0xFFFF9800),
    ];
    return colors[h % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Ask a question card
        if (widget.isStudent)
          FuturexContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask the community',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: FuturexColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _askController,
                  maxLines: 3,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type your study question here...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: const Color(0xFFF8FAFC),
                    filled: true,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: FuturexColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: _ask,
                    style: FilledButton.styleFrom(
                      backgroundColor: FuturexColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: Text(
                      'Post Question',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Questions thread header
        if (_questions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
            child: Text(
              'DISCUSSION FORUM (${_questions.length})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: FuturexColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
          ),

        // Threaded list of questions
        ..._questions.map((q) {
          final m = q as Map;
          final qid = m['_id']?.toString() ?? '';
          final qText = m['questionText']?.toString() ?? '';
          final qAuthor = m['studentId'] is Map
              ? (m['studentId']['fullName']?.toString() ?? 'Student')
              : 'Student';
          final initial = qAuthor.isNotEmpty ? qAuthor[0].toUpperCase() : 'S';

          // Check for replies/answers in the question payload
          final answers = (m['answers'] ?? m['replies'] ?? []) as List;

          return FuturexContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Author Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _getAvatarColor(qAuthor),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            qAuthor,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: FuturexColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Asked question',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: FuturexColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Question Content Text
                Text(
                  qText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: FuturexColors.textPrimary,
                    height: 1.45,
                  ),
                ),
                
                // Render answers/replies list
                if (answers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  ...answers.map((ans) {
                    final ansMap = ans is Map ? ans : {};
                    final ansText = ansMap['content']?.toString() ?? ans.toString();
                    final ansAuthor = ansMap['authorName']?.toString() ?? 'Tutor';
                    final ansInitial = ansAuthor.isNotEmpty ? ansAuthor[0].toUpperCase() : 'T';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 2,
                            height: 36,
                            margin: const EdgeInsets.only(right: 12, left: 6),
                            color: FuturexColors.primary.withValues(alpha: 0.3),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: FuturexColors.success.withValues(alpha: 0.8),
                                        child: Text(
                                          ansInitial,
                                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        ansAuthor,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.5,
                                          color: FuturexColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: FuturexColors.success.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Answer',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: FuturexColors.success,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    ansText,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      color: FuturexColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                // Answer Input Section (for Teachers/Tutors)
                if (!widget.isStudent) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _getAnswerController(qid),
                          style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: 'Type your explanation...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            fillColor: const Color(0xFFF1F5F9),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: FuturexColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _answer(qid),
                        icon: const Icon(Icons.send_rounded, color: FuturexColors.primary, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: FuturexColors.primary.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
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
                'No questions asked yet.',
                style: GoogleFonts.plusJakartaSans(color: FuturexColors.textSecondary),
              ),
            ),
          ),
      ],
    );
  }
}
