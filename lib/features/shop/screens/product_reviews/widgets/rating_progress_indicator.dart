import 'package:flutter/material.dart';
import 'package:t_store/features/shop/controllers/product/review_controller.dart';
import 'package:t_store/features/shop/screens/product_reviews/widgets/product_indicator_and_rating.dart';

class TOverallProductRating extends StatelessWidget {
  final ReviewController controller;

  const TOverallProductRating({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            controller.averageRating.value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        Expanded(
          flex: 7,
          child: Column(
            children: [
              TRatingProgressIndicator(text: '5', value: controller.getRatingPercentage(5)),
              TRatingProgressIndicator(text: '4', value: controller.getRatingPercentage(4)),
              TRatingProgressIndicator(text: '3', value: controller.getRatingPercentage(3)),
              TRatingProgressIndicator(text: '2', value: controller.getRatingPercentage(2)),
              TRatingProgressIndicator(text: '1', value: controller.getRatingPercentage(1)),
            ],
          ),
        )
      ],
    );
  }
}
