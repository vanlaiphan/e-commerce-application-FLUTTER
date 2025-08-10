// review_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:t_store/data/repositories/authentication/authentication_repository.dart';
import 'package:t_store/data/repositories/user/user_repository.dart';
import 'package:t_store/features/shop/models/review_model.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/popups/loaders.dart';

import '../../../../data/repositories/reviews/review_repository.dart';

class ReviewController extends GetxController {
  static ReviewController get instance => Get.find();

  final isLoading = false.obs;
  final rating = 1.0.obs;
  final reviewFormKey = GlobalKey<FormState>();
  final commentController = TextEditingController();

  final reviewRepository = Get.put(ReviewRepository());
  final userRepository = Get.put(UserRepository());

  RxList<ReviewModel> productReviews = <ReviewModel>[].obs;
  final averageRating = 0.0.obs;
  final totalReviews = 0.obs;
  final ratingDistribution = <int, int>{}.obs;

  // Add current product ID to track which product we're viewing
  final currentProductId = ''.obs;

  /// Reset form
  void resetForm() {
    rating.value = 1.0;
    commentController.clear();
  }

  /// Submit review
  Future<bool> submitReview(String productId) async {
    try {
      // Start Loading
      isLoading.value = true;

      // Form validation
      if (!reviewFormKey.currentState!.validate()) {
        isLoading.value = false;
        return false;
      }

      // Check if user is logged in
      final authRepo = AuthenticationRepository.instance;

      // Get current user data
      final userData = await userRepository.fetchUserDetails();

      // Create review
      final review = ReviewModel(
        id: '',
        productId: productId,
        userId: authRepo.authUser.uid,
        userName: userData.fullName,
        userImage: userData.profilePicture.isNotEmpty
            ? userData.profilePicture
            : TImages.user,
        rating: rating.value,
        comment: commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Add review to database
      await reviewRepository.addReview(review);

      // Show success message
      TLoaders.successSnackBar(
        title: 'Review Submitted',
        message: 'Thank you for your review!',
      );

      // Reset form
      resetForm();

      // Return success
      return true;

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch product reviews
  Future<void> fetchProductReviews(String productId) async {
    try {
      isLoading.value = true;

      // Set current product ID
      currentProductId.value = productId;

      // Fetch reviews
      final reviews = await reviewRepository.getProductReviews(productId);
      productReviews.assignAll(reviews);

      // Fetch review statistics
      await fetchReviewStats(productId);

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch review statistics
  Future<void> fetchReviewStats(String productId) async {
    try {
      final stats = await reviewRepository.getReviewStats(productId);

      averageRating.value = stats['averageRating'];
      totalReviews.value = stats['totalReviews'];
      ratingDistribution.value = Map<int, int>.from(stats['ratingDistribution']);

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Calculate rating percentage for progress indicator
  double getRatingPercentage(int starRating) {
    if (totalReviews.value == 0) return 0.0;
    int count = ratingDistribution[starRating] ?? 0;
    return count / totalReviews.value;
  }

  /// Delete review (if user owns it)
  Future<void> deleteReview(String reviewId, String userId) async {
    try {
      // Check if current user owns the review
      final authRepo = AuthenticationRepository.instance;
      if (authRepo.authUser.uid != userId) {
        TLoaders.errorSnackBar(
          title: 'Access Denied',
          message: 'You can only delete your own reviews',
        );
        return;
      }

      isLoading.value = true;

      await reviewRepository.deleteReview(reviewId);

      // Remove from local list
      productReviews.removeWhere((review) => review.id == reviewId);

      // **FIX: Refresh stats after deletion**
      if (currentProductId.value.isNotEmpty) {
        await fetchReviewStats(currentProductId.value);
      }

      TLoaders.successSnackBar(
        title: 'Review Deleted',
        message: 'Your review has been deleted successfully',
      );

    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if current user can review this product
  bool canUserReview(String productId) {
    final authRepo = AuthenticationRepository.instance;

    // Check if user already reviewed this product
    bool hasReviewedAlready = productReviews.any(
          (review) => review.userId == authRepo.authUser.uid,
    );

    return !hasReviewedAlready;
  }

  /// **NEW: Method to refresh reviews after adding/updating**
  Future<void> refreshReviews() async {
    if (currentProductId.value.isNotEmpty) {
      await fetchProductReviews(currentProductId.value);
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}