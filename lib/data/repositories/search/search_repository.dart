import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:t_store/features/shop/models/brand_model.dart';
import 'package:t_store/features/shop/models/product_model.dart';

class SearchRepository extends GetxController {
  static SearchRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Search products with Firestore queries (more efficient for large datasets)
  Future<List<ProductModel>> searchProductsInFirestore(String query) async {
    try {
      final querySnapshot = await _db
          .collection('Products')
          .where('Title', isGreaterThanOrEqualTo: query)
          .where('Title', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) => ProductModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Something went wrong while searching products. Please try again.';
    }
  }

  /// Search brands with Firestore queries
  Future<List<BrandModel>> searchBrandsInFirestore(String query) async {
    try {
      final querySnapshot = await _db
          .collection('Brands')
          .where('Name', isGreaterThanOrEqualTo: query)
          .where('Name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) => BrandModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw 'Something went wrong while searching brands. Please try again.';
    }
  }

  /// Get popular search terms (for suggestions)
  Future<List<String>> getPopularSearchTerms() async {
    try {
      // This would typically come from a separate collection tracking search analytics
      // For now, return static suggestions
      return [
        'Nike',
        'Adidas',
        'iPhone',
        'Samsung',
        'Laptop',
        'Headphones',
        'Shoes',
        'Clothing',
        'Electronics',
        'Sports',
      ];
    } catch (e) {
      return [];
    }
  }

  /// Save search query for analytics (optional)
  Future<void> saveSearchQuery(String query) async {
    try {
      await _db.collection('SearchAnalytics').add({
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Silently fail - analytics shouldn't break the search functionality
    }
  }
}