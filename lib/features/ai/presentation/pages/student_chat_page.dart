import 'package:finalyearproject/features/ai/data/ai_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentChatPage extends StatefulWidget {
  const StudentChatPage({
    super.key,
    this.topicId,
    this.topicName,
    this.page,
    this.prefilledPrompt,
  });

  final String? topicId;
  final String? topicName;
  final String? page;
  final String? prefilledPrompt;

  @override
  State<StudentChatPage> createState() => _StudentChatPageState();
}

class _StudentChatPageState extends State<StudentChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  // ChatGPT Dark slate theme colors
  // Replaced with dynamic theme colors in build()
  static const Color userBubbleBg = Color(0xFF4F46E5); // Indigo 600

  @override
  void initState() {
    super.initState();
    if (widget.prefilledPrompt != null && widget.prefilledPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendText(widget.prefilledPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendText(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
    });
    _scrollToBottom();

    try {
      final answer = await AiRemoteDataSource().chat(
        message: text,
        topicId: widget.topicId,
        page: widget.page,
      );
      setState(() => _messages.add({'role': 'ai', 'text': answer}));
    } catch (e) {
      setState(() => _messages.add({'role': 'ai', 'text': 'Error: ${e.toString()}'}));
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _sendText(text);
  }

  void _clearChat() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          'Clear conversation?',
          style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will delete all messages in this session.',
          style: GoogleFonts.plusJakartaSans(color: subtextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _messages.clear());
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = Theme.of(context).scaffoldBackgroundColor;
    final textCol = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: bgCol,
        elevation: 0,
        iconTheme: IconThemeData(color: textCol),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textCol, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981), // Pulsing green dot
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AI Study Partner',
              style: GoogleFonts.outfit(
                color: textCol,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: isDark ? Colors.white70 : Colors.black54),
              onPressed: _clearChat,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
            ),
            if (_loading) _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleCol = isDark ? Colors.white : Colors.black87;
    final subCol = isDark ? Colors.white60 : Colors.black54;
    
    final title = widget.topicName ?? 'your studies';
    final suggestion1 = widget.topicName != null
        ? 'Explain "${widget.topicName}" in simple terms'
        : 'Explain Organic Chemistry in simple terms';
    final suggestion2 = widget.topicName != null
        ? 'Give me a 3-question quiz on "${widget.topicName}"'
        : 'Give me a 3-question quiz on Algebra';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Pulsing AI Icon container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: userBubbleBg.withValues(alpha: 0.1),
              border: Border.all(color: userBubbleBg.withValues(alpha: 0.25), width: 2),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: userBubbleBg,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'How can I help with $title?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: titleCol,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'I can explain concepts, quiz you, or solve problems. Try one of the starters below:',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: subCol,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),
          _buildSuggestionChip(suggestion1, Icons.lightbulb_outline_rounded),
          _buildSuggestionChip(suggestion2, Icons.quiz_outlined),
          _buildSuggestionChip('Summarize key formulas for exam prep', Icons.menu_book_rounded),
          _buildSuggestionChip('Tell me how to manage my exam time', Icons.timer_outlined),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String prompt, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardCol = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    final textCol = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cardCol,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _sendText(prompt),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.indigo.shade300, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    prompt,
                    style: GoogleFonts.plusJakartaSans(
                      color: textCol,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: isDark ? Colors.white30 : Colors.black26, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aiCardCol = isDark ? const Color(0xFF1E293B) : Colors.white;
    final aiTextCol = isDark ? Colors.white.withValues(alpha: 0.95) : Colors.black87;
    final codeBg = isDark ? Colors.black26 : Colors.grey.shade100;
    final codeCol = isDark ? Colors.amberAccent : Colors.indigo;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        final isUser = m['role'] == 'user';
        final text = m['text'] ?? '';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  margin: const EdgeInsets.only(right: 10, top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: userBubbleBg.withValues(alpha: 0.15),
                    border: Border.all(color: userBubbleBg.withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.indigoAccent, size: 16),
                ),
              ],
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? userBubbleBg : aiCardCol,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                    border: isUser ? null : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: isUser
                      ? Text(
                          text,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        )
                      : MarkdownBody(
                          data: text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              color: aiTextCol,
                              height: 1.5,
                            ),
                            h1: GoogleFonts.outfit(color: aiTextCol, fontWeight: FontWeight.bold, fontSize: 18),
                            h2: GoogleFonts.outfit(color: aiTextCol, fontWeight: FontWeight.bold, fontSize: 16),
                            h3: GoogleFonts.outfit(color: aiTextCol, fontWeight: FontWeight.bold, fontSize: 14),
                            code: TextStyle(backgroundColor: codeBg, color: codeCol, fontSize: 13),
                            codeblockDecoration: BoxDecoration(
                              color: codeBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            listBullet: GoogleFonts.plusJakartaSans(color: aiTextCol),
                          ),
                        ),
                ),
              ),
              if (isUser) const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardCol = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: userBubbleBg.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.indigoAccent, size: 16),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardCol,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: SizedBox(
                width: 36,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) => const _PulsingDot()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = Theme.of(context).scaffoldBackgroundColor;
    final inputCol = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.2);
    final textCol = isDark ? Colors.white : Colors.black87;
    final hintCol = isDark ? Colors.white38 : Colors.black38;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgCol,
        border: Border(top: BorderSide(color: borderCol)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputCol,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderCol),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: textCol, fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'Ask anything...',
                  hintStyle: TextStyle(color: hintCol),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: const BoxDecoration(
              color: userBubbleBg,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _submit,
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: isDark ? Colors.white70 : Colors.black54,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
