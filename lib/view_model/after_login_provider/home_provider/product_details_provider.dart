import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/product_details_res_model.dart';
import 'package:samagrah/repo/product_repo.dart';

final productDetailsRepo = Provider((ref) => ProductRepo());

final productDetailsProvider =
    FutureProvider.family<ProductDetailsResModel, String>((ref, id) async {
      final repo = ref.read(productDetailsRepo);
      return repo.productDetails(id);
    });
