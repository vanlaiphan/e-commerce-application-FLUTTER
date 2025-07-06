import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:t_store/common/widgets/shimmers/vertical_product_shimmer.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/controllers/category_controller.dart';
import 'package:t_store/features/shop/models/category_model.dart';
import 'package:t_store/features/shop/screens/all_products/all_products.dart';
import 'package:t_store/features/shop/screens/store/widgets/category_brands.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helpers/cloud_helper_functions.dart';

class TCategoryTab extends StatelessWidget {
  const TCategoryTab({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// -- Brands
              CategoryBrands(category: category),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// -- Products
              FutureBuilder(
                  future: controller.getCategoryProducts(categoryId: category.id),
                  builder: (context, snapshot) {
                    /// Helper Function: Handle Loader, No Record, OR ERROR Message
                    final response = TCloudHelperFunctions.checkMultiRecordState(snapshot: snapshot, loader: const TVerticalProductShimmer());
                    if (response != null) return response;

                    /// Record Found!
                    final products = snapshot.data!;

                    return Column(
                      children: [
                        TSectionHeading(
                          title: 'You might like',
                          onPressed: () => Get.to(AllProducts(
                              title: category.name,
                              futureMethod: controller.getCategoryProducts(categoryId: category.id, limit: -1),
                            ),
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        TGridLayout(itemCount: products.length, itemBuilder: (_, index) => TProductCardVertical(product: products[index])),
                      ],
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
