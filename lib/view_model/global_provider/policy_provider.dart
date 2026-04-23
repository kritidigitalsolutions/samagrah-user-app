import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/policy_res/policy_res_model.dart';
import 'package:samagrah/repo/policy_repo.dart';

final policyRepoProvider = Provider((ref) => PolicyRepo());

final termsProvider = FutureProvider<PolicyResModel>((ref) async {
  final repo = ref.read(policyRepoProvider);
  return repo.getTerm();
});

final privacyProvider = FutureProvider<PolicyResModel>((ref) async {
  final repo = ref.read(policyRepoProvider);
  return repo.getPrivacy();
});
