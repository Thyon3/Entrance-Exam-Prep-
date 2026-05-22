import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/content/data/content_remote_data_source.dart';
import 'package:flutter/material.dart';

class TopicExercisePage extends StatefulWidget {
  const TopicExercisePage({super.key, required this.topicId, this.isStudent = true});
  final String topicId;
  final bool isStudent;

  @override
  State<TopicExercisePage> createState() => _TopicExercisePageState();
}

class _TopicExercisePageState extends State<TopicExercisePage> {
  List<dynamic> _exercises = [];
  bool _loading = true;
  final Map<String, int> _selected = {};
  final Map<String, String?> _feedback = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ContentRemoteDataSource().getExercises(widget.topicId);
    setState(() {
      _exercises = list;
      _loading = false;
    });
  }

  Future<void> _submit(String exerciseId) async {
    final answer = _selected[exerciseId];
    if (answer == null) return;
    try {
      final res = await ContentRemoteDataSource()
          .submitExercise(exerciseId, answer);
      setState(() {
        _feedback[exerciseId] = res is Map && res['isCorrect'] == true
            ? 'Correct!'
            : 'Incorrect. ${res is Map ? res['correctAnswer'] ?? '' : ''}';
      });
    } catch (e) {
      setState(() => _feedback[exerciseId] = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _exercises.length,
      itemBuilder: (context, i) {
        final ex = _exercises[i] as Map;
        final id = ex['_id']?.toString() ?? '';
        final question = ex['question']?.toString() ?? 'Question';
        final options =
            (ex['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
        return FuturexContentCard(
          title: 'Question ${i + 1}',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question, style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 12),
              ...options.asMap().entries.map((e) => RadioListTile<int>(
                    title: Text(e.value),
                    value: e.key,
                    groupValue: _selected[id],
                    onChanged: widget.isStudent
                        ? (v) {
                            if (v != null) setState(() => _selected[id] = v);
                          }
                        : null,
                  )),
              if (widget.isStudent) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submit(id),
                    child: const Text('Submit answer'),
                  ),
                ),
                if (_feedback[id] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _feedback[id]!,
                      style: TextStyle(
                        color: _feedback[id]!.startsWith('Correct')
                            ? FuturexColors.success
                            : FuturexColors.error,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
