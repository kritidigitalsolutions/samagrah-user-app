import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/category_res_model.dart';
import 'package:samagrah/repo/product_repo.dart';
import 'package:samagrah/views/service_pages/location_provider.dart';

/// City ke basis pe categories fetch karta hai
final categoryProvider = FutureProvider<List<CategoryData>>((ref) async {
  final location = ref.watch(locationProvider);

  // Location nahi hai to empty list return karo
  final city = location?.city;
  if (city == null || city.isEmpty) return [];

  final repo = ProductRepo();
  final res = await repo.getCategories();
  return res.data;
});
