import 'package:finalyearproject/core/widgets/loading_view.dart';
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
      appBar: AppBar(title: const Text('My reports')),
      body: _loading
          ? const LoadingView()
          : ListView.builder(
              itemCount: _issues.length,
              itemBuilder: (context, i) {
                final m = _issues[i] as Map;
                return ListTile(
                  title: Text(m['description']?.toString() ?? ''),
                  subtitle: Text('${m['issueType']} · ${m['issueStatus']}'),
                );
              },
            ),
    );
  }
}
