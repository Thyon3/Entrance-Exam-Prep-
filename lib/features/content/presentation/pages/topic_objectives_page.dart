import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/curriculum/application/curriculum_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicObjectivesPage extends ConsumerStatefulWidget {
  const TopicObjectivesPage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  ConsumerState<TopicObjectivesPage> createState() => _TopicObjectivesPageState();
}

class _TopicObjectivesPageState extends ConsumerState<TopicObjectivesPage> {
  List<String> _objectives = [];
  final _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final topic = await ref.read(curriculumRemoteDataSourceProvider).getTopic(widget.topicId);
    setState(() {
      _objectives = topic.objectives ?? [];
      _loading = false;
    });
  }

  Future<void> _save() async {
    final lines = _controller.text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    await ref.read(curriculumRemoteDataSourceProvider).updateTopic(widget.topicId, {
      'topicObjectives': lines,
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();
    if (!widget.isStudent) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FuturexContentCard(
            title: 'Edit objectives',
            child: Column(
              children: [
                TextField(
                  controller: _controller..text = _objectives.join('\n'),
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'One objective per line',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _save, child: const Text('Save objectives')),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (_objectives.isEmpty) {
      return const Center(child: Text('No objectives listed yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _objectives.length,
      itemBuilder: (context, i) => FuturexContentCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(child: Text(_objectives[i], style: const TextStyle(fontSize: 15))),
          ],
        ),
      ),
    );
  }
}
