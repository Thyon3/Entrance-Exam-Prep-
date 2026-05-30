import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finalyearproject/core/network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
