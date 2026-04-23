import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/view_model/global_provider/policy_provider.dart';

class PolicyPage extends ConsumerWidget {
  final String title;
  final bool isTerms;

  const PolicyPage({super.key, required this.title, required this.isTerms});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = isTerms
        ? ref.watch(termsProvider)
        : ref.watch(privacyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: AppColors.background),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text("Error: $e")),

        data: (res) {
          final content = res.legal?.content ?? "";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          );
        },
      ),
    );
  }
}
