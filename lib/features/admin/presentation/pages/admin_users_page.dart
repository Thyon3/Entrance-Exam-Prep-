import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/features/admin/presentation/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ref.read(adminRemoteDataSourceProvider).listUsers();
      setState(() {
        _users = data is Map && data['users'] is List
            ? data['users'] as List
            : (data is List ? data : []);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _setStatus(String id, String status) async {
    await ref.read(adminRemoteDataSourceProvider).updateUserStatus(id, status);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const FuturexLoadingBody();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, i) {
          final u = _users[i] as Map;
          final id = u['_id']?.toString() ?? '';
          final name = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
          return FuturexContentCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(name.isNotEmpty ? name[0] : '?'),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${u['email']} · ${u['role']} · ${u['status']}'),
              trailing: PopupMenuButton<String>(
                onSelected: (s) => _setStatus(id, s),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'active', child: Text('Active')),
                  PopupMenuItem(value: 'suspended', child: Text('Suspended')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
