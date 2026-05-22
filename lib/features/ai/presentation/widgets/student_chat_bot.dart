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
        backgroundColor: Colors.blue.shade700,
        onPressed: () => setState(() => _open = true),
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text('AI Tutor'),
      );
    }
    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: MediaQuery.of(context).size.width - 32,
        height: 360,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text('AI Study Assistant',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _open = false),
                ),
              ],
            ),
            const Divider(),
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
                        color: isUser ? Colors.blue.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(m['text'] ?? '', style: const TextStyle(fontSize: 14)),
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
                    decoration: InputDecoration(
                      hintText: 'Ask anything...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  onPressed: _send,
                  icon: Icon(Icons.send, color: Colors.blue.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
