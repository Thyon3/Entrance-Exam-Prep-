import 'package:finalyearproject/core/widgets/loading_view.dart';
import 'package:finalyearproject/features/admin/data/admin_remote_data_source.dart';
import 'package:flutter/material.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRemoteDataSource().listUsers();
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
    await AdminRemoteDataSource().updateUserStatus(id, status);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, i) {
          final u = _users[i] as Map;
          final id = u['_id']?.toString() ?? '';
          final name = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
          return Card(
            child: ListTile(
              title: Text(name),
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
