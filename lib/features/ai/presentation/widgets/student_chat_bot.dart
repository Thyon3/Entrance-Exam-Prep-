import 'package:finalyearproject/core/constants/app_colors.dart';
import 'package:finalyearproject/features/ai/data/ai_remote_data_source.dart';
import 'package:flutter/material.dart';

class StudentChatBot extends StatefulWidget {
  const StudentChatBot({super.key, this.topicId, this.page});

  final String? topicId;
  final String? page;

  @override
  State<StudentChatBot> createState() => _StudentChatBotState();
}

class _StudentChatBotState extends State<StudentChatBot> {
  bool _open = false;
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _controller.clear();
    try {
      final answer = await AiRemoteDataSource().chat(
        message: text,
        topicId: widget.topicId,
        page: widget.page,
      );
      setState(() => _messages.add({'role': 'ai', 'text': answer}));
    } catch (e) {
      setState(() => _messages.add({'role': 'ai', 'text': e.toString()}));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_open) {
      return FloatingActionButton.extended(
        onPressed: () => setState(() => _open = true),
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text('AI Tutor'),
      );
    }
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        height: 360,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Text('AI Study Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _open = false),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isUser = m['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.primary.withValues(alpha: 0.1) : AppColors.outline,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(m['text'] ?? ''),
                    ),
                  );
                },
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Ask anything...'),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
