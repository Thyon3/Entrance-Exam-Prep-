import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/chapter_form_page.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_list_page.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter/material.dart';

class ChapterListPage extends StatefulWidget {
  const ChapterListPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
    this.isStudent = true,
  });

  final String subjectId;
  final String subjectName;
  final bool isStudent;

  @override
  State<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage> {
  List<ChapterModel> _chapters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final chapters = await CurriculumRemoteDataSource()
          .getChaptersBySubject(widget.subjectId);
      if (widget.isStudent) {
        final progress = await EngagementRemoteDataSource()
            .getSubjectChapterProgress(widget.subjectId);
        final map = <String, double>{};
        if (progress is List) {
          for (final p in progress) {
            if (p is Map) {
              final cid = (p['chapterId']?['_id'] ?? p['chapterId'])?.toString();
              final pct = (p['completionPercentage'] as num?)?.toDouble();
              if (cid != null && pct != null) map[cid] = pct;
            }
          }
        }
        setState(() {
          _chapters = chapters
              .map((c) => ChapterModel(
                    id: c.id,
                    chapterName: c.chapterName,
                    subjectId: c.subjectId,
                    completionPercent: map[c.id],
                  ))
              .toList();
          _loading = false;
        });
      } else {
        setState(() {
          _chapters = chapters;
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.subjectName)),
      floatingActionButton: widget.isStudent
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChapterFormPage(subjectId: widget.subjectId),
                  ),
                );
                if (ok == true) _load();
              },
              child: const Icon(Icons.add),
            ),
      body: _loading
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _chapters.length,
                itemBuilder: (context, i) {
                  final c = _chapters[i];
                  return Card(
                    child: ListTile(
                      title: Text(c.chapterName),
                      subtitle: widget.isStudent && c.completionPercent != null
                          ? LinearProgressIndicator(value: c.completionPercent! / 100)
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicListPage(
                            chapterId: c.id,
                            chapterName: c.chapterName,
                            subjectId: widget.subjectId,
                            isStudent: widget.isStudent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
