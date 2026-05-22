import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_subject_card.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
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
      final chapters =
          await CurriculumRemoteDataSource().getChaptersBySubject(widget.subjectId);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: widget.subjectName,
        showNotificationIcon: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      floatingActionButton: widget.isStudent
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blue.shade700,
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
          ? const FuturexLoadingBody(message: 'Loading chapters...')
          : RefreshIndicator(
              onRefresh: _load,
              child: _chapters.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        FuturexEmptyState(
                          title: 'No chapters yet',
                          message: 'Chapters will appear here once added.',
                          icon: Icons.menu_book_outlined,
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _chapters.length,
                      itemBuilder: (context, i) {
                        final c = _chapters[i];
                        return FuturexSimpleListCard(
                          title: c.chapterName,
                          subtitle: widget.isStudent && c.completionPercent != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: c.completionPercent! / 100,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade200,
                                    color: const Color(0xFF388E3C),
                                  ),
                                )
                              : null,
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
                        );
                      },
                    ),
            ),
    );
  }
}
