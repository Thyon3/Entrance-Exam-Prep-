import 'package:finalyearproject/core/network/api_client_provider.dart';
import 'package:finalyearproject/features/engagement/data/engagement_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final engagementRemoteDataSourceProvider = Provider<EngagementRemoteDataSource>(
  (ref) => EngagementRemoteDataSource(ref.watch(apiClientProvider)),
);
