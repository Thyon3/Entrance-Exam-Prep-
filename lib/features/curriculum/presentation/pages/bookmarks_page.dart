import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_list_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/engagement/application/engagement_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarksPage extends ConsumerStatefulWidget {
  const BookmarksPage({super.key, this.embedded = false, this.bottomInset = 0});

  final bool embedded;
  final double bottomInset;

  @override
  ConsumerState<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends ConsumerState<BookmarksPage> {
  List<dynamic> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ref.read(engagementRemoteDataSourceProvider).getBookmarks();
      setState(() {
        _bookmarks = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _remove(String id) async {
    await ref.read(engagementRemoteDataSourceProvider).removeBookmark(id);
    _load();
  }

  Widget _buildList() {
    if (_loading) return const FuturexLoadingBody(message: 'Loading bookmarks...');

    if (_bookmarks.isEmpty) {
      return FuturexEmptyState(
        title: 'No bookmarks yet',
        message: 'Save topics while studying to find them here quickly.',
        icon: Icons.bookmark_outline_rounded,
        onAction: _load,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: FuturexColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 12, 16, widget.bottomInset + 16),
        itemCount: _bookmarks.length,
        itemBuilder: (context, i) {
          final b = _bookmarks[i] as Map;
          final id = b['_id']?.toString() ?? '';
          final type = b['resourceType']?.toString() ?? 'Bookmark';
          return FuturexListCard(
            title: type,
            subtitle: Text(
              b['note']?.toString() ?? b['resourceId']?.toString() ?? '',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FuturexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bookmark_rounded, color: FuturexColors.primary),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: FuturexColors.error),
              onPressed: () => _remove(id),
            ),
            onTap: null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(title: 'Bookmarks', showNotificationIcon: false),
      body: _buildList(),
    );
  }
}
