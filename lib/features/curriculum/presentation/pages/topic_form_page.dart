import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/curriculum/application/curriculum_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicFormPage extends ConsumerStatefulWidget {
  const TopicFormPage({super.key, required this.chapterId});
  final String chapterId;

  @override
  ConsumerState<TopicFormPage> createState() => _TopicFormPageState();
}

class _TopicFormPageState extends ConsumerState<TopicFormPage> {
  final _name = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(curriculumRemoteDataSourceProvider).createTopic(
        widget.chapterId,
        {'topicName': _name.text.trim()},
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(title: 'New topic', showNotificationIcon: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FuturexContentCard(
          title: 'Topic details',
          child: Column(
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Topic name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
