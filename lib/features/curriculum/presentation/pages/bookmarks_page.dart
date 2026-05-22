import 'package:finalyearproject/core/widgets/loading_view.dart';
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
      appBar: AppBar(title: const Text('Bookmarks')),
      body: _loading
          ? const LoadingView()
          : ListView.builder(
              itemCount: _bookmarks.length,
              itemBuilder: (context, i) {
                final b = _bookmarks[i] as Map;
                final id = b['_id']?.toString() ?? '';
                return ListTile(
                  title: Text(b['resourceType']?.toString() ?? 'Bookmark'),
                  subtitle: Text(b['note']?.toString() ?? b['resourceId']?.toString() ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _remove(id),
                  ),
                );
              },
            ),
    );
  }
}
