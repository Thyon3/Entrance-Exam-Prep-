import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter/material.dart';

class TeacherQaPage extends StatefulWidget {
  const TeacherQaPage({super.key});

  @override
  State<TeacherQaPage> createState() => _TeacherQaPageState();
}

class _TeacherQaPageState extends State<TeacherQaPage> {
  List<dynamic> _questions = [];
  List<dynamic> _issues = [];
  final _answer = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final engagement = EngagementRemoteDataSource();
    try {
      final q = await engagement.listQuestions();
      final issues = await engagement.getIssuesForReview();
      setState(() {
        _questions = q;
        _issues = issues;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _answerQuestion(String qid) async {
    if (_answer.text.trim().isEmpty) return;
    await EngagementRemoteDataSource()
        .answerQuestion(qid, _answer.text.trim());
    _answer.clear();
    _load();
  }

  Future<void> _updateIssue(String id, String status) async {
    await EngagementRemoteDataSource().updateIssueStatus(id, status);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.blue.shade700,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue.shade700,
              tabs: const [
                Tab(text: 'Questions'),
                Tab(text: 'Issues'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: _questions.map((q) {
                    final m = q as Map;
                    final id = m['_id']?.toString() ?? '';
                    return FuturexContentCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['questionText']?.toString() ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _answer,
                            decoration: const InputDecoration(
                              labelText: 'Answer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _answerQuestion(id),
                              child: const Text('Submit'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: _issues.map((i) {
                    final m = i as Map;
                    final id = m['_id']?.toString() ?? '';
                    return FuturexContentCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(m['description']?.toString() ?? ''),
                        subtitle: Text(m['issueStatus']?.toString() ?? ''),
                        trailing: PopupMenuButton<String>(
                          onSelected: (s) => _updateIssue(id, s),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'resolved', child: Text('Resolved')),
                            PopupMenuItem(value: 'in_progress', child: Text('In progress')),
                            PopupMenuItem(value: 'rejected', child: Text('Rejected')),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
