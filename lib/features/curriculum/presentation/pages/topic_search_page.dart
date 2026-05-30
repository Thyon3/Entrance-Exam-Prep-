import 'dart:async';

import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_list_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/curriculum/application/curriculum_providers.dart';
import 'package:finalyearproject/features/curriculum/domain/curriculum_models.dart';
import 'package:finalyearproject/features/curriculum/presentation/pages/topic_detail_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicSearchPage extends ConsumerStatefulWidget {
  const TopicSearchPage({super.key, this.embedded = false});

  /// When true, renders without its own [Scaffold] (used inside [StudentMainLayout]).
  final bool embedded;

  @override
  ConsumerState<TopicSearchPage> createState() => _TopicSearchPageState();
}

class _TopicSearchPageState extends ConsumerState<TopicSearchPage> {
  final _query = TextEditingController();
  List<TopicModel> _results = [];
  bool _searching = false;
  bool _searched = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.removeListener(_onSearchChanged);
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_query.text.trim().length < 2) {
      setState(() {
        _results = [];
        _searching = false;
        _searched = false;
      });
      return;
    }
    setState(() {
      _searching = true;
      _searched = true;
    });
    try {
      final list =
          await ref.read(curriculumRemoteDataSourceProvider).searchTopics(_query.text.trim());
      setState(() {
        _results = list;
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  Widget _buildBody({double bottomInset = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: FuturexColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded, color: FuturexColors.primary),
                  Expanded(
                    child: TextField(
                      controller: _query,
                      decoration: const InputDecoration(
                        hintText: 'Search topics by name...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  IconButton(
                    onPressed: _searching ? null : _search,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    color: FuturexColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_searching)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(),
          ),
        Expanded(
          child: _searching
              ? const FuturexLoadingBody(message: 'Searching...')
              : !_searched
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomInset),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.travel_explore_rounded,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Find any topic',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter at least 2 characters',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _results.isEmpty
                      ? FuturexEmptyState(
                          title: 'No results',
                          message: 'Try a different search term.',
                          icon: Icons.search_off_rounded,
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            bottomInset + 16,
                          ),
                          itemCount: _results.length,
                          itemBuilder: (context, i) {
                            final t = _results[i];
                            return FuturexListCard(
                              title: t.topicName,
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: FuturexColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.topic_rounded,
                                  color: FuturexColors.primary,
                                ),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TopicDetailShellPage(
                                    topicId: t.id,
                                    topicName: t.topicName,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildBody(bottomInset: 152 + MediaQuery.paddingOf(context).bottom);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: 'Search topics',
        showNotificationIcon: false,
      ),
      body: _buildBody(),
    );
  }
}
