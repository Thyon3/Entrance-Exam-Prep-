import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_list_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/engagement/application/engagement_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ref.read(engagementRemoteDataSourceProvider).getAllNotifications();
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markRead(String id) async {
    await ref.read(engagementRemoteDataSourceProvider).markNotificationRead(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: 'Notifications',
        subtitle: _loading ? null : '${_items.length} total',
        showNotificationIcon: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const FuturexLoadingBody()
          : _items.isEmpty
              ? const FuturexEmptyState(
                  title: 'All caught up',
                  message: 'You have no notifications right now.',
                  icon: Icons.notifications_none_rounded,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: FuturexColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final n = _items[i] as Map;
                      final id = n['_id']?.toString() ?? '';
                      final read = n['readStatus'] == true;
                      final title =
                          n['title']?.toString() ?? n['message']?.toString() ?? 'Notification';
                      return FuturexListCard(
                        title: title,
                        subtitle: Text(
                          n['message']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: read ? FontWeight.normal : FontWeight.w500,
                          ),
                        ),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: read
                              ? Colors.grey.shade200
                              : FuturexColors.primary,
                          child: Icon(
                            read
                                ? Icons.notifications_none_rounded
                                : Icons.notifications_active_rounded,
                            color: read ? Colors.grey : Colors.white,
                            size: 22,
                          ),
                        ),
                        trailing: read
                            ? null
                            : TextButton(
                                onPressed: () => _markRead(id),
                                child: const Text('Mark read'),
                              ),
                        onTap: read ? null : () => _markRead(id),
                      );
                    },
                  ),
                ),
    );
  }
}
