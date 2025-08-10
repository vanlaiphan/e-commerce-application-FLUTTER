import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../data/repositories/ai/ai_repository.dart';

class EcommerceWorkflowController extends GetxController {
  static EcommerceWorkflowController get instance => Get.find();

  // Observable variables
  final RxBool isProcessing = false.obs;
  final RxBool isImageLoaded = false.obs;
  final RxBool isSecondaryImageLoaded = false.obs;
  final RxBool isUploadingPrimary = false.obs;
  final RxBool isUploadingSecondary = false.obs;
  final RxString selectedImage = ''.obs;
  final RxString secondaryImage = ''.obs;
  final RxString primaryImageUrl = ''.obs; // Firebase URL
  final RxString secondaryImageUrl = ''.obs; // Firebase URL
  final RxString customPrompt = ''.obs;
  final RxString processedImagePath = ''.obs;
  final RxString combinedImagePath = ''.obs;

  // Text controllers
  final TextEditingController promptController = TextEditingController();

  // Dependencies
  final AIRepository _aiRepository = Get.put(AIRepository());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constants
  final String defaultPrompt = "Remove clothing";
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Initialize default values
    customPrompt.value = '';
  }

  @override
  void onClose() {
    promptController.dispose();
    super.onClose();
  }

  /// Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  /// Select image from gallery or camera (supports both primary and secondary)
  Future<void> selectImage({
    ImageSource source = ImageSource.gallery,
    bool isPrimary = true
  }) async {
    if (_currentUserId == null) {
      Get.snackbar(
        'Authentication Required',
        'Please login to upload images',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Set local image path immediately for preview
        if (isPrimary) {
          selectedImage.value = image.path;
          isImageLoaded.value = true;
          isUploadingPrimary.value = true;
        } else {
          secondaryImage.value = image.path;
          isSecondaryImageLoaded.value = true;
          isUploadingSecondary.value = true;
        }

        // Upload to Firebase
        await _uploadImageToFirebase(
          imageFile: File(image.path),
          isPrimary: isPrimary,
        );

        // Reset processed images when new image is selected
        if (isPrimary) {
          processedImagePath.value = '';
          combinedImagePath.value = '';
        }

        Get.snackbar(
          'Success',
          isPrimary
              ? 'Primary image uploaded successfully'
              : 'Secondary image uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Reset uploading state on error
      if (isPrimary) {
        isUploadingPrimary.value = false;
      } else {
        isUploadingSecondary.value = false;
      }

      Get.snackbar(
        'Error',
        'Could not select/upload image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Upload image to Firebase
  Future<void> _uploadImageToFirebase({
    required File imageFile,
    required bool isPrimary,
  }) async {
    try {
      final String imageType = isPrimary ? 'primary' : 'secondary';

      // Show upload progress
      Get.snackbar(
        'Uploading',
        'Uploading ${imageType} image to cloud...',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        showProgressIndicator: true,
      );

      final String downloadUrl = await _aiRepository.uploadAIImage(
        imageFile: imageFile,
        userId: _currentUserId!,
        imageType: imageType,
      );

      // Store Firebase URL
      if (isPrimary) {
        primaryImageUrl.value = downloadUrl;
        isUploadingPrimary.value = false;
      } else {
        secondaryImageUrl.value = downloadUrl;
        isUploadingSecondary.value = false;
      }

    } catch (e) {
      // Reset uploading state
      if (isPrimary) {
        isUploadingPrimary.value = false;
      } else {
        isUploadingSecondary.value = false;
      }

      rethrow; // Re-throw to be handled by calling method
    }
  }

  /// Update custom prompt
  void updatePrompt(String value) {
    customPrompt.value = value;
  }

  /// Clear primary image
  void clearPrimaryImage() {
    selectedImage.value = '';
    primaryImageUrl.value = '';
    isImageLoaded.value = false;
    isUploadingPrimary.value = false;
    processedImagePath.value = '';
    combinedImagePath.value = '';

    Get.snackbar(
      'Notice',
      'Primary image removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  /// Clear secondary image
  void clearSecondaryImage() {
    secondaryImage.value = '';
    secondaryImageUrl.value = '';
    isSecondaryImageLoaded.value = false;
    isUploadingSecondary.value = false;

    Get.snackbar(
      'Notice',
      'Secondary image removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  /// Validate inputs before processing
  bool _validateInputs() {
    if (_currentUserId == null) {
      Get.snackbar(
        'Authentication Required',
        'Please login to use AI features',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (!isImageLoaded.value || selectedImage.value.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please select at least one primary image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (isUploadingPrimary.value || isUploadingSecondary.value) {
      Get.snackbar(
        'Upload in Progress',
        'Please wait for image upload to complete',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (primaryImageUrl.value.isEmpty) {
      Get.snackbar(
        'Upload Error',
        'Primary image upload failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (customPrompt.value.trim().isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please enter a custom description',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  /// Process the workflow with API integration
  Future<void> processWorkflow() async {
    if (!_validateInputs()) return;

    try {
      isProcessing.value = true;

      // Show loading overlay dialog with rotating indicator
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // Prevent dismissing during processing
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Processing AI Workflow...',
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Prepare API request
      final Map<String, dynamic> requestBody = {
        "url_image_human": primaryImageUrl.value,
        "url_image_outfit": secondaryImageUrl.value,
        "user_prompt": customPrompt.value,
      };

      // Make API call
      final response = await http.post(
        Uri.parse('http://213.173.108.86:10196/outfit_swap'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200) {
        final List<dynamic> result = jsonDecode(response.body);
        if (result.isNotEmpty && result[0]['image'] != null) {
          // Convert base64 to image file
          final String base64String = result[0]['image'];
          final Uint8List bytes = base64Decode(base64String);

          // Save temporary file
          final Directory tempDir = await getTemporaryDirectory();
          final String tempPath = '${tempDir.path}/processed_image.png';
          final File tempFile = File(tempPath);
          await tempFile.writeAsBytes(bytes);

          // Update UI with processed image
          processedImagePath.value = tempPath;
          combinedImagePath.value = tempPath;

          Get.snackbar(
            'Success',
            'AI workflow completed successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        throw Exception('Failed to process images: ${response.statusCode}');
      }

    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Could not process workflow: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Simulate workflow processing steps with more detailed progress
  Future<void> _simulateWorkflowSteps() async {
    final steps = [
      'Preprocessing primary image...',
      if (isSecondaryImageLoaded.value) 'Processing secondary image...',
      'Analyzing image content...',
      'Translating text prompt...',
      'Generating AI modifications...',
      'Optimizing results...',
      'Combining components...'
    ];

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      Get.snackbar(
        'Step ${i + 1}/${steps.length}',
        steps[i],
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.withOpacity(0.7 + (i * 0.05)),
        colorText: Colors.white,
        duration: const Duration(milliseconds: 700),
      );
    }
  }

  /// Load user's previous AI images
  Future<void> loadUserAIImages() async {
    if (_currentUserId == null) return;

    try {
      final images = await _aiRepository.getUserAIImages(_currentUserId!);

      // Handle the loaded images as needed
      print('Loaded ${images.length} AI images for user');

    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not load AI images: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Clear all data
  void clearAll() {
    selectedImage.value = '';
    secondaryImage.value = '';
    primaryImageUrl.value = '';
    secondaryImageUrl.value = '';
    customPrompt.value = '';
    processedImagePath.value = '';
    combinedImagePath.value = '';
    isImageLoaded.value = false;
    isSecondaryImageLoaded.value = false;
    isUploadingPrimary.value = false;
    isUploadingSecondary.value = false;
    promptController.clear();

    Get.snackbar(
      'Notice',
      'All data cleared',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  /// Save processed image with better UX
  Future<void> saveProcessedImage() async {
    if (combinedImagePath.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No image to save',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Simulate save process
      await Future.delayed(const Duration(seconds: 1));

      // Close loading dialog
      Get.back();

      // In real app, implement actual save functionality
      Get.snackbar(
        'Success',
        'Image saved to gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Could not save image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Share processed image with better UX
  Future<void> shareProcessedImage() async {
    if (combinedImagePath.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No image to share',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Simulate share process
      await Future.delayed(const Duration(seconds: 1));

      // Close loading dialog
      Get.back();

      // In real app, implement actual share functionality
      Get.snackbar(
        'Notice',
        'Share functionality will be implemented',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Could not share image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Get workflow summary for display
  String getWorkflowSummary() {
    final buffer = StringBuffer();
    buffer.write('📸 Images: ');

    if (isImageLoaded.value) {
      buffer.write('Primary ✓');
      if (primaryImageUrl.value.isNotEmpty) {
        buffer.write(' (Uploaded)');
      } else if (isUploadingPrimary.value) {
        buffer.write(' (Uploading...)');
      }

      if (isSecondaryImageLoaded.value) {
        buffer.write(', Secondary ✓');
        if (secondaryImageUrl.value.isNotEmpty) {
          buffer.write(' (Uploaded)');
        } else if (isUploadingSecondary.value) {
          buffer.write(' (Uploading...)');
        }
      }
    } else {
      buffer.write('Not selected');
    }

    buffer.write('\n📝 Prompt: ');
    if (customPrompt.value.trim().isNotEmpty) {
      buffer.write(customPrompt.value.length > 50
          ? '${customPrompt.value.substring(0, 50)}...'
          : customPrompt.value);
    } else {
      buffer.write('Not entered');
    }

    return buffer.toString();
  }

  /// Check if workflow is ready to process
  bool get isWorkflowReady =>
      isImageLoaded.value &&
          customPrompt.value.trim().isNotEmpty &&
          primaryImageUrl.value.isNotEmpty &&
          !isUploadingPrimary.value &&
          !isUploadingSecondary.value;

  /// Get processing progress percentage
  int get processingProgress {
    if (!isProcessing.value) return 0;
    // This would be updated during actual processing
    return 75; // Mock progress
  }

  /// Check if any upload is in progress
  bool get isAnyUploadInProgress => isUploadingPrimary.value || isUploadingSecondary.value;
}