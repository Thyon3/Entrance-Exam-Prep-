import 'package:finalyearproject/features/curriculum/data/curriculum_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final curriculumRemoteDataSourceProvider = Provider<CurriculumRemoteDataSource>(
  (ref) => CurriculumRemoteDataSource(),
);
