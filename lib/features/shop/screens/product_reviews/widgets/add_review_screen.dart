import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/features/shop/controllers/product/review_controller.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/validators/validation.dart';

import '../../../../../common/widgets/images/t_rounded_image.dart';

class AddReviewScreen extends StatelessWidget {
  final ProductModel product;

  const AddReviewScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewController());
    controller.resetForm();

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Write a Review'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: controller.reviewFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Product Info
                Container(
                  padding: const EdgeInsets.all(TSizes.sm),
                  decoration: BoxDecoration(
                    border: Border.all(color: TColors.grey),
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  ),
                  child: Row(
                    children: [
                      TRoundedImage(
                        imageUrl: product.thumbnail,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        borderRadius: TSizes.sm,
                        isNetworkImage: true,
                      ),
                      const SizedBox(width: TSizes.spaceBtwItems),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (product.brand != null)
                              Text(
                                product.brand!.name,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Rating
                Text(
                  'Your Rating',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Obx(
                      () => RatingBar.builder(
                    initialRating: controller.rating.value,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: TColors.primary,
                    ),
                    onRatingUpdate: (rating) {
                      controller.rating.value = rating;
                    },
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Comment
                Text(
                  'Your Review',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                TextFormField(
                  controller: controller.commentController,
                  validator: (value) => TValidator.validateEmptyText('Review', value),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this product...',
                    prefixIcon: const Icon(Icons.comment),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Submit Button
                Obx(
                      () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                        // **FIX: Submit review and return success status**
                        final success = await controller.submitReview(product.id);
                        if (success) {
                          // Return true to indicate successful submission
                          Get.back(result: true);
                        }
                      },
                      child: controller.isLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text('Submit Review'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}