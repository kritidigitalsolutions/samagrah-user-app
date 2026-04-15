import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

final userProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final token = await AuthLocalstorageService.getToken();
  print(token);
  return await AuthLocalstorageService.getUser();
});
