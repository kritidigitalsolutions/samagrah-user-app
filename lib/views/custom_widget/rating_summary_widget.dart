import 'package:flutter/material.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/textstyle.dart';

class RatingSummaryWidget extends StatelessWidget {
  final Ratings ratings;

  const RatingSummaryWidget({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    final counts = ratings.counts;

    if (counts == null) return const SizedBox.shrink();

    final ratingMap = {
      5: counts.rating5 ?? 0,
      4: counts.rating4 ?? 0,
      3: counts.rating3 ?? 0,
      2: counts.rating2 ?? 0,
      1: counts.rating1 ?? 0,
    };

    final total = ratingMap.values.fold(0, (sum, item) => sum + item);

    Color getColor(int rating) {
      switch (rating) {
        case 5:
        case 4:
          return Colors.green;
        case 3:
          return Colors.amber;
        case 2:
          return Colors.orange;
        default:
          return Colors.red;
      }
    }

    String getLabel(int rating) {
      switch (rating) {
        case 5:
          return "Very Good";
        case 4:
          return "Good";
        case 3:
          return "Ok-Ok";
        case 2:
          return "Bad";
        default:
          return "Very Bad";
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Customer Reviews", style: text16(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Left rating box
              Container(
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: const BoxDecoration(
                        color: AppColors.button,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${ratings.average ?? 0}",
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(Icons.star, color: Colors.white, size: 26),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            "$total ratings",
                            style: text13(color: AppColors.grey700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${ratings.totalReviews ?? 0} reviews",
                            style: text13(color: AppColors.grey700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              /// Right bars
              Expanded(
                child: Column(
                  children: ratingMap.entries.map((entry) {
                    final rating = entry.key;
                    final count = entry.value;
                    final progress = total == 0 ? 0.0 : count / total;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(getLabel(rating), style: text13()),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(
                                  getColor(rating),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            child: Text(
                              count.toString(),
                              textAlign: TextAlign.end,
                              style: text12(color: AppColors.grey700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
