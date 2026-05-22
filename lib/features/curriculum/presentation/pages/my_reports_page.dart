import 'package:finalyearproject/core/widgets/futurex/futurex_content_card.dart';
import 'package:finalyearproject/core/widgets/futurex/futurex_loader.dart';
import 'package:finalyearproject/core/widgets/futurex/gradient_app_bar.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter/material.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  List<dynamic> _issues = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await EngagementRemoteDataSource().getMyIssues();
    setState(() {
      _issues = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const GradientAppBar(title: 'My reports', showNotificationIcon: false),
      body: _loading
          ? const FuturexLoadingBody()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _issues.length,
              itemBuilder: (context, i) {
                final m = _issues[i] as Map;
                return FuturexContentCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(m['description']?.toString() ?? ''),
                    subtitle: Text('${m['issueType']} · ${m['issueStatus']}'),
                    leading: Icon(Icons.flag_outlined, color: Colors.orange.shade700),
                  ),
                );
              },
            ),
    );
  }
}
