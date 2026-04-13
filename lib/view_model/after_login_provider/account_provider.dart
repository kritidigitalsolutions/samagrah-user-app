import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

final userProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return await AuthLocalstorageService.getUser();
});