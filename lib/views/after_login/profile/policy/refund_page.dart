import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/global_provider/policy_provider.dart';

class RefundPage extends ConsumerWidget {
  const RefundPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(refundProvider);

    return Scaffold(
      appBar: CustomAppBar(title: "Refund Policy"),
      backgroundColor: AppColors.background,
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text("Error: $e")),

        data: (res) {
          final content = res.legal?.content ?? "";
          print("about us ------- $content");

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(content, style: text14()),
          );
        },
      ),
    );
  }
}
