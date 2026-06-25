import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/sub_category_res_model.dart';
import 'package:samagrah/repo/product_repo.dart';
import 'package:samagrah/views/service_pages/location_provider.dart';

final subCategoryProvider = FutureProvider<List<SubCategoryData>>((ref) async {
  ref.watch(locationProvider);

  final repo = ProductRepo();
  final res = await repo.getSubCategories();
  return res.data;
});
