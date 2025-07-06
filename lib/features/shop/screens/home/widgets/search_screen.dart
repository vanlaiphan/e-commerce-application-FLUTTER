import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/common/widgets/brands/brand_card.dart';
import 'package:t_store/common/widgets/layouts/grid_layout.dart';
import 'package:t_store/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:t_store/common/widgets/texts/section_heading.dart';
import 'package:t_store/features/shop/controllers/product/product_controller.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

import '../../../controllers/search_controller.dart';
import '../../all_products/all_products.dart';
import '../../brand/all_brands.dart';

class TSearchDelegate extends SearchDelegate<String> {
  final TSearchController searchController = Get.put(TSearchController());
  final productController = ProductController.instance;

  @override
  String get searchFieldLabel => 'Search products, brands...';

  @override
  TextStyle get searchFieldStyle => const TextStyle(fontSize: 16);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          searchController.clearSearch();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    searchController.searchQuery(query);
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildSearchResults(context);
    }

    final suggestions = searchController.getSearchSuggestions(query);

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.search),
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Obx(() {
      if (searchController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final hasProducts = searchController.searchProducts.isNotEmpty;
      final hasBrands = searchController.searchBrands.isNotEmpty;

      // Show "no results" only when user has searched and found nothing
      if (!hasProducts && !hasBrands && searchController.currentQuery.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: dark ? TColors.darkGrey : TColors.grey,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'No results found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              Text(
                'Try different keywords',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show search query info
            if (searchController.currentQuery.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: TSizes.spaceBtwSections),
                child: Row(
                  children: [
                    if (searchController.searchBrands.isEmpty && searchController.searchProducts.isNotEmpty)
                      // When filtering by brand
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(TSizes.sm),
                          decoration: BoxDecoration(
                            color: dark ? TColors.dark : TColors.light,
                            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                            border: Border.all(color: TColors.grey.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.filter_list, size: 16, color: TColors.primary),
                              const SizedBox(width: TSizes.spaceBtwItems / 2),
                              Text(
                                'Filtered by: ${searchController.currentQuery.value}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  searchController.searchQuery('');
                                  query = '';
                                  showResults(context);
                                },
                                child: const Icon(Icons.clear, size: 16, color: TColors.darkGrey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // When searching
                      Expanded(
                        child: Text(
                          'Results for "${searchController.currentQuery.value}"',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                  ],
                ),
              ),

            // Featured Brands Section - Show when no search query OR when search has brand results
            if (hasBrands) ...[
              TSectionHeading(
                title: searchController.currentQuery.value.isEmpty ? 'Featured Brands' : 'Brands',
                onPressed: () => Get.to(() => const AllBrandsScreen()),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 1.5),

              // Brands Grid
              TGridLayout(
                itemCount: searchController.searchBrands.length,
                mainAxisExtent: 80,
                itemBuilder: (context, index) {
                  final brand = searchController.searchBrands[index];
                  return TBrandCard(
                    brand: brand,
                    showBorder: true,
                    onTap: () {
                      searchController.filterByBrand(brand.name);
                      query = brand.name;
                      showResults(context);
                    },
                  );
                },
              ),

              const SizedBox(height: TSizes.spaceBtwSections),
            ],

            // Products Section
            if (hasProducts) ...[
              TSectionHeading(
                title: searchController.currentQuery.value.isEmpty ? 'Popular Products' : 'Products',
                onPressed: () => Get.to(
                  () => AllProducts(title: 'All Products', futureMethod: productController.fetchAllFeaturedProducts()),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Products Grid
              TGridLayout(
                itemCount: searchController.searchProducts.length,
                itemBuilder: (context, index) {
                  final product = searchController.searchProducts[index];
                  return TProductCardVertical(product: product);
                },
              ),
            ],
          ],
        ),
      );
    });
  }
}
