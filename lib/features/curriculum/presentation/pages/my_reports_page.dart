import 'package:finalyearproject/core/constants/futurex_colors.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_list_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_states.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/engagement/application/engagement_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyReportsPage extends ConsumerStatefulWidget {
  const MyReportsPage({super.key});

  @override
  ConsumerState<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends ConsumerState<MyReportsPage> {
  List<dynamic> _issues = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ref.read(engagementRemoteDataSourceProvider).getMyIssues();
      setState(() {
        _issues = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('resolved') || s.contains('closed')) return FuturexColors.success;
    if (s.contains('pending') || s.contains('open')) return const Color(0xFFE65100);
    return FuturexColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(
        title: 'My reports',
        subtitle: _loading ? null : '${_issues.length} submitted',
        showNotificationIcon: false,
      ),
      body: _loading
          ? const FuturexLoadingBody()
          : _issues.isEmpty
              ? const FuturexEmptyState(
                  title: 'No reports yet',
                  message: 'Issues you report from topics will show up here.',
                  icon: Icons.flag_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: FuturexColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _issues.length,
                    itemBuilder: (context, i) {
                      final m = _issues[i] as Map;
                      final status = m['issueStatus']?.toString() ?? '';
                      final type = m['issueType']?.toString() ?? '';
                      final color = _statusColor(status);
                      return FuturexListCard(
                        title: m['description']?.toString() ?? 'Report',
                        badge: type.isNotEmpty ? type : null,
                        iconColor: color,
                        subtitle: Text(
                          status,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.flag_rounded, color: color),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
