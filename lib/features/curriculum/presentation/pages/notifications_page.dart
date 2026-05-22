import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await EngagementRemoteDataSource().getAllNotifications();
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _markRead(String id) async {
    await EngagementRemoteDataSource().markNotificationRead(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _loading
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final n = _items[i] as Map;
                  final id = n['_id']?.toString() ?? '';
                  final read = n['readStatus'] == true;
                  return ListTile(
                    title: Text(n['title']?.toString() ?? n['message']?.toString() ?? 'Notification'),
                    subtitle: Text(n['message']?.toString() ?? ''),
                    trailing: read ? null : TextButton(onPressed: () => _markRead(id), child: const Text('Read')),
                  );
                },
              ),
            ),
    );
  }
}
