import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: 'Notifications',
        showNotificationIcon: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const FuturexLoadingBody()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final n = _items[i] as Map;
                  final id = n['_id']?.toString() ?? '';
                  final read = n['readStatus'] == true;
                  return FuturexContentCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: read ? Colors.grey.shade300 : Colors.blue.shade700,
                        child: Icon(
                          read ? Icons.notifications_none : Icons.notifications_active,
                          color: read ? Colors.grey : Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        n['title']?.toString() ?? n['message']?.toString() ?? 'Notification',
                        style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold),
                      ),
                      subtitle: Text(n['message']?.toString() ?? ''),
                      trailing: read
                          ? null
                          : TextButton(onPressed: () => _markRead(id), child: const Text('Read')),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
