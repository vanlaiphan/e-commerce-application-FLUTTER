import 'package:get/get.dart';
import 'package:t_store/features/shop/controllers/product/product_controller.dart';
import 'package:t_store/features/shop/models/brand_model.dart';
import 'package:t_store/features/shop/models/product_model.dart';
import 'package:t_store/utils/popups/loaders.dart';

import 'brand_controller.dart';

class TSearchController extends GetxController {
  static TSearchController get instance => Get.find();

  final RxList<ProductModel> searchProducts = <ProductModel>[].obs;
  final RxList<BrandModel> searchBrands = <BrandModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentQuery = ''.obs;

  final productController = ProductController.instance;
  final brandController = Get.put(BrandController());

  @override
  void onInit() {
    super.onInit();
    // Wait for brand controller to load data first
    ever(brandController.isLoading, (isLoading) {
      if (!isLoading) {
        // Initialize with all products and featured brands
        searchProducts.assignAll(productController.featuredProducts);

        // Use featured brands if available, otherwise use all brands (limited to 4)
        if (brandController.featuredBrands.isNotEmpty) {
          searchBrands.assignAll(brandController.featuredBrands);
        } else {
          searchBrands.assignAll(brandController.allBrands.take(4));
        }

        // Debug print
        print('SearchController initialized:');
        print('Products count: ${searchProducts.length}');
        print('Brands count: ${searchBrands.length}');
        print('Featured brands: ${brandController.featuredBrands.length}');
        print('All brands: ${brandController.allBrands.length}');
      }
    });
  }

  /// Search for products and brands
  Future<void> searchQuery(String query) async {
    try {
      if (query.isEmpty) {
        // If query is empty, show featured products and featured brands
        searchProducts.assignAll(productController.featuredProducts);
        searchBrands.assignAll(brandController.featuredBrands);
        currentQuery.value = '';
        return;
      }

      isLoading.value = true;
      currentQuery.value = query;

      // Search in products
      final filteredProducts = productController.featuredProducts.where((product) {
        return product.title.toLowerCase().contains(query.toLowerCase()) ||
            product.brand?.name.toLowerCase().contains(query.toLowerCase()) == true ||
            product.description?.toLowerCase().contains(query.toLowerCase()) == true;
      }).toList();

      // Search in brands - only show brands that have matching products or matching name
      final filteredBrands = brandController.allBrands.where((brand) {
        final brandNameMatch = brand.name.toLowerCase().contains(query.toLowerCase());
        final hasMatchingProducts = filteredProducts.any((product) =>
        product.brand?.name.toLowerCase() == brand.name.toLowerCase());
        return brandNameMatch || hasMatchingProducts;
      }).toList();

      searchProducts.assignAll(filteredProducts);
      searchBrands.assignAll(filteredBrands);
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Search Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter products by specific brand
  void filterByBrand(String brandName) {
    final filteredProducts = productController.featuredProducts.where((product) {
      return product.brand?.name.toLowerCase() == brandName.toLowerCase();
    }).toList();

    searchProducts.assignAll(filteredProducts);
    searchBrands.clear(); // Clear brands when filtering by specific brand
    currentQuery.value = brandName;
  }

  /// Get search suggestions based on input
  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return [];

    final suggestions = <String>[];

    // Add matching product titles
    for (var product in productController.featuredProducts) {
      if (product.title.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(product.title);
      }
    }

    // Add matching brand names
    for (var brand in brandController.allBrands) {
      if (brand.name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(brand.name);
      }
    }

    // Remove duplicates and limit to 5 suggestions
    return suggestions.toSet().take(5).toList();
  }

  /// Clear search results
  void clearSearch() {
    searchProducts.assignAll(productController.featuredProducts);

    // Use featured brands if available, otherwise use all brands (limited to 4)
    if (brandController.featuredBrands.isNotEmpty) {
      searchBrands.assignAll(brandController.featuredBrands);
    } else {
      searchBrands.assignAll(brandController.allBrands.take(4));
    }

    currentQuery.value = '';
  }
}