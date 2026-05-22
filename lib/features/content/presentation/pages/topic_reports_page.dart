import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter/material.dart';

class TopicReportsPage extends StatefulWidget {
  const TopicReportsPage({super.key, required this.topicId});
  final String topicId;

  @override
  State<TopicReportsPage> createState() => _TopicReportsPageState();
}

class _TopicReportsPageState extends State<TopicReportsPage> {
  List<dynamic> _issues = [];
  final _desc = TextEditingController();
  String _type = 'content_error';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await EngagementRemoteDataSource().getMyIssues();
    setState(() {
      _issues = all.where((i) {
        if (i is! Map) return false;
        final tid = (i['topicId']?['_id'] ?? i['topicId'])?.toString();
        return tid == widget.topicId;
      }).toList();
      _loading = false;
    });
  }

  Future<void> _submit() async {
    await EngagementRemoteDataSource().createIssue({
      'topicId': widget.topicId,
      'issueType': _type,
      'description': _desc.text.trim(),
    });
    _desc.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          value: _type,
          decoration: const InputDecoration(labelText: 'Issue type'),
          items: const [
            DropdownMenuItem(value: 'content_error', child: Text('Content error')),
            DropdownMenuItem(value: 'technical', child: Text('Technical')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (v) => setState(() => _type = v ?? 'content_error'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _desc,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Description'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _submit, child: const Text('Submit report')),
        const SizedBox(height: 20),
        const Text('Your reports', style: TextStyle(fontWeight: FontWeight.w600)),
        ..._issues.map((i) {
          final m = i as Map;
          return ListTile(
            title: Text(m['description']?.toString() ?? ''),
            subtitle: Text(m['issueStatus']?.toString() ?? 'pending'),
          );
        }),
      ],
    );
  }
}
