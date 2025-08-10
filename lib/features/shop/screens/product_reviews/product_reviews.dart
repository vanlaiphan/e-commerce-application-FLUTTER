// enhanced_product_reviews.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/features/shop/controllers/product/review_controller.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/features/shop/screens/product_reviews/widgets/add_review_screen.dart';
import 'package:t_store/features/shop/screens/product_reviews/widgets/rating_progress_indicator.dart';
import 'package:t_store/features/shop/screens/product_reviews/widgets/updated_user_review_card.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/constants/colors.dart';

import '../../../../common/widgets/products/ratings/rating_indicator.dart';

class ProductReviewsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductReviewsScreen({super.key, required this.product});

  // Helper method to navigate to AddReviewScreen
  Future<void> _navigateToAddReview(ReviewController controller) async {
    final result = await Get.to(() => AddReviewScreen(product: product));
    if (result == true) {
      controller.refreshReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewController());

    // Fetch reviews when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProductReviews(product.id);
    });

    return Scaffold(
      /// -- Appbar
      appBar: TAppBar(
        title: const Text('Reviews & Ratings'),
        showBackArrow: true,
        actions: [
          // Add Review Button in AppBar
          Obx(() {
            if (controller.canUserReview(product.id)) {
              return IconButton(
                onPressed: () => _navigateToAddReview(controller),
                icon: const Icon(Icons.add_comment),
                tooltip: 'Write a review',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),

      /// -- Body
      body: Obx(() {
        if (controller.isLoading.value && controller.productReviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshReviews(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ratings and reviews are verified and are from people who use the same type of device that you use.",
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Overall Product Ratings
                  TOverallProductRating(controller: controller),
                  TRatingBarIndicator(rating: controller.averageRating.value),
                  Text(
                    "${controller.totalReviews.value} reviews",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Add Review Button (Prominent placement)
                  Obx(() {
                    if (controller.canUserReview(product.id)) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: TSizes.spaceBtwSections),
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToAddReview(controller),
                          icon: const Icon(Icons.edit),
                          label: const Text('Write a Review'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  /// User Reviews List
                  if (controller.productReviews.isEmpty && !controller.isLoading.value)
                    _buildEmptyReviewsState(context, controller)
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.productReviews.length,
                      itemBuilder: (context, index) {
                        final review = controller.productReviews[index];
                        return UpdatedUserReviewCard(
                          review: review,
                          onDelete: () => controller.deleteReview(review.id, review.userId),
                        );
                      },
                    ),

                  /// Loading indicator for additional reviews
                  if (controller.isLoading.value && controller.productReviews.isNotEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(TSizes.defaultSpace),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  /// Bottom spacing for FAB
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      }),

      /// Floating Action Button for quick review access
      floatingActionButton: Obx(() {
        if (controller.canUserReview(product.id)) {
          return FloatingActionButton.extended(
            onPressed: () => _navigateToAddReview(controller),
            backgroundColor: TColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.rate_review),
            label: const Text('Review'),
            tooltip: 'Write a review',
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  /// Build empty reviews state with call-to-action
  Widget _buildEmptyReviewsState(BuildContext context, ReviewController controller) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: TSizes.spaceBtwSections * 2),
          Icon(
            Icons.comment,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'No reviews yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems / 2),
          Text(
            'Be the first to review this product!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Call-to-action button in empty state
          if (controller.canUserReview(product.id))
            ElevatedButton.icon(
              onPressed: () => _navigateToAddReview(controller),
              icon: const Icon(Icons.star_rate),
              label: const Text('Write First Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.spaceBtwSections,
                  vertical: TSizes.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
              ),
            ),
        ],
      ),
    );
  }
}