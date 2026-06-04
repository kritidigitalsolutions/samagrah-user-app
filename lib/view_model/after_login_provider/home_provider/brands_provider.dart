import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/brands_res_model.dart';
import 'package:samagrah/repo/product_repo.dart';
import 'package:samagrah/views/service_pages/location_provider.dart';

final brandProvider = FutureProvider<List<BrandsData>>((ref) async {
  final location = ref.watch(locationProvider);
  final city = location?.city;
  if (city == null || city.isEmpty) return [];
  final repo = ProductRepo();
  final res = await repo.getBrands();
  return res.data;
});
