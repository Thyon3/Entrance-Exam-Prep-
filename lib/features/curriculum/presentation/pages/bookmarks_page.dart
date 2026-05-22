import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter/material.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<dynamic> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await EngagementRemoteDataSource().getBookmarks();
    setState(() {
      _bookmarks = list;
      _loading = false;
    });
  }

  Future<void> _remove(String id) async {
    await EngagementRemoteDataSource().removeBookmark(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const GradientAppBar(title: 'Bookmarks', showNotificationIcon: false),
      body: _loading
          ? const FuturexLoadingBody()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookmarks.length,
              itemBuilder: (context, i) {
                final b = _bookmarks[i] as Map;
                final id = b['_id']?.toString() ?? '';
                return FuturexContentCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.bookmark, color: Colors.blue.shade700),
                    title: Text(b['resourceType']?.toString() ?? 'Bookmark'),
                    subtitle: Text(b['note']?.toString() ?? b['resourceId']?.toString() ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _remove(id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
