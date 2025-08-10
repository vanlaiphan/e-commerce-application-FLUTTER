// review_repository.dart - ENHANCED VERSION
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:t_store/features/shop/models/review_model.dart';
import 'package:t_store/utils/exceptions/firebase_exceptions.dart';
import 'package:t_store/utils/exceptions/platform_exceptions.dart';

class ReviewRepository extends GetxController {
  static ReviewRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Get all reviews for a specific product
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final snapshot = await _db
          .collection('Reviews')
          .where('ProductId', isEqualTo: productId)
          .orderBy('CreatedAt', descending: true)
          .get();
      return snapshot.docs.map((e) => ReviewModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Add a new review - ENHANCED VERSION
  Future<String> addReview(ReviewModel review) async {
    try {
      final docRef = await _db.collection('Reviews').add(review.toJson());
      return docRef.id; // Return the document ID for immediate local update
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get a single review by ID - NEW METHOD
  Future<ReviewModel?> getReviewById(String reviewId) async {
    try {
      final snapshot = await _db.collection('Reviews').doc(reviewId).get();
      if (snapshot.exists && snapshot.data() != null) {
        return ReviewModel.fromSnapshot(snapshot);
      }
      return null;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Update a review
  Future<void> updateReview(String reviewId, Map<String, dynamic> data) async {
    try {
      await _db.collection('Reviews').doc(reviewId).update(data);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _db.collection('Reviews').doc(reviewId).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Get review statistics for a product
  Future<Map<String, dynamic>> getReviewStats(String productId) async {
    try {
      final snapshot = await _db
          .collection('Reviews')
          .where('ProductId', isEqualTo: productId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0}
        };
      }

      double totalRating = 0;
      Map<int, int> ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var doc in snapshot.docs) {
        double rating = double.parse((doc.data()['Rating'] ?? 0.0).toString());
        totalRating += rating;
        int ratingInt = rating.round();
        ratingDistribution[ratingInt] = (ratingDistribution[ratingInt] ?? 0) + 1;
      }

      double averageRating = totalRating / snapshot.docs.length;

      return {
        'averageRating': averageRating,
        'totalReviews': snapshot.docs.length,
        'ratingDistribution': ratingDistribution
      };
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Stream reviews for real-time updates - NEW METHOD
  Stream<List<ReviewModel>> streamProductReviews(String productId) {
    return _db
        .collection('Reviews')
        .where('ProductId', isEqualTo: productId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList());
  }
}