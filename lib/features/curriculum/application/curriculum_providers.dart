import 'package:finalyearproject/core/network/api_client_provider.dart';
import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final curriculumRemoteDataSourceProvider = Provider<CurriculumRemoteDataSource>(
  (ref) => CurriculumRemoteDataSource(ref.watch(apiClientProvider)),
);
