import 'package:finalyearproject/core/network/api_client_provider.dart';
import 'package:finalyearproject/features/admin/data/admin_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>(
  (ref) => AdminRemoteDataSource(ref.watch(apiClientProvider)),
);
