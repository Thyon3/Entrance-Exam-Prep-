import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/features/ai/presentation/pages/student_chat_page.dart';
import 'package:flutter/material.dart';

class StudentChatBot extends StatelessWidget {
  const StudentChatBot({super.key, this.topicId, this.topicName, this.page});

  final String? topicId;
  final String? topicName;
  final String? page;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: FuturexColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'student_chat_bot_fab',
        backgroundColor: FuturexColors.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentChatPage(
                topicId: topicId,
                topicName: topicName,
                page: page,
              ),
            ),
          );
        },
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
