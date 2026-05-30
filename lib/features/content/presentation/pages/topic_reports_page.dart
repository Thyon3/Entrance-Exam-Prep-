import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/engagement/application/engagement_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicReportsPage extends ConsumerStatefulWidget {
  const TopicReportsPage({super.key, required this.topicId});
  final String topicId;

  @override
  ConsumerState<TopicReportsPage> createState() => _TopicReportsPageState();
}

class _TopicReportsPageState extends ConsumerState<TopicReportsPage> {
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
    final all = await ref.read(engagementRemoteDataSourceProvider).getMyIssues();
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
    await ref.read(engagementRemoteDataSourceProvider).createIssue({
      'topicId': widget.topicId,
      'issueType': _type,
      'description': _desc.text.trim(),
    });
    _desc.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        FuturexContentCard(
          title: 'Report an issue',
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Issue type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                items: const [
                  DropdownMenuItem(value: 'content_error', child: Text('Content error')),
                  DropdownMenuItem(value: 'technical', child: Text('Technical')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'content_error'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _desc,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _submit, child: const Text('Submit report')),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Your reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ),
        ..._issues.map((i) {
          final m = i as Map;
          return FuturexContentCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(m['description']?.toString() ?? ''),
              subtitle: Text(m['issueStatus']?.toString() ?? 'pending'),
            ),
          );
        }),
      ],
    );
  }
}
