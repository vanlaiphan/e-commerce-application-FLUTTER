import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/common/widgets/appbar/appbar.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';
import '../../controllers/ai_controller.dart';

class EcommerceWorkflowScreen extends StatelessWidget {
  const EcommerceWorkflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EcommerceWorkflowController());
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const TAppBar(
        title: Text('E-Commerce AI'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Section
            _buildHeaderSection(context, isDark),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Image Selection Section
            _buildImageSelectionSection(controller, isDark),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Upload Status Section
            _buildUploadStatusSection(controller, isDark),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Custom Prompt Section
            _buildCustomPromptSection(controller, isDark),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Processing Section
            _buildProcessingSection(controller, isDark),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Results Section
            _buildResultsSection(controller, isDark),
          ],
        ),
      ),
    );
  }

  /// Header Section with Dark Mode Support
  Widget _buildHeaderSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [TColors.primary.withOpacity(0.2), TColors.primary.withOpacity(0.1)]
              : [TColors.primary.withOpacity(0.1), TColors.primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
        border: Border.all(
            color: isDark
                ? TColors.primary.withOpacity(0.3)
                : TColors.primary.withOpacity(0.2)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_fix_high,
                color: TColors.primary,
                size: TSizes.iconLg,
              ),
              const SizedBox(width: TSizes.sm),
              Text(
                'AI Image Processing',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            'Upload images to cloud storage and use AI to create professional e-commerce visuals',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? TColors.grey : TColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced Image Selection Section with Multiple Images and Upload Status
  Widget _buildImageSelectionSection(EcommerceWorkflowController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Images',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TColors.white : TColors.textPrimary,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// Primary Image
        Text(
          'Human',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? TColors.grey : TColors.textSecondary,
          ),
        ),
        const SizedBox(height: TSizes.sm),

        Obx(() => controller.isImageLoaded.value
            ? _buildSelectedImage(controller, isDark, isPrimary: true)
            : _buildImageSelector(controller, isDark, isPrimary: true)),

        const SizedBox(height: TSizes.spaceBtwItems),

        /// Secondary Image (Optional)
        Text(
          'Outfit',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? TColors.grey : TColors.textSecondary,
          ),
        ),
        const SizedBox(height: TSizes.sm),

        Obx(() => controller.isSecondaryImageLoaded.value
            ? _buildSelectedImage(controller, isDark, isPrimary: false)
            : _buildImageSelector(controller, isDark, isPrimary: false)),
      ],
    );
  }

  /// Upload Status Section
  Widget _buildUploadStatusSection(EcommerceWorkflowController controller, bool isDark) {
    return Obx(() {
      if (!controller.isAnyUploadInProgress &&
          controller.primaryImageUrl.value.isEmpty &&
          controller.secondaryImageUrl.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: isDark ? TColors.dark : TColors.lightContainer,
          borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
          border: Border.all(
            color: isDark ? TColors.grey.withOpacity(0.3) : TColors.borderPrimary,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: TColors.primary,
                  size: TSizes.iconMd,
                ),
                const SizedBox(width: TSizes.sm),
                Text(
                  'Upload Status',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TColors.white : TColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.sm),

            // Primary Image Status
            if (controller.isImageLoaded.value)
              _buildImageUploadStatus(
                'Human Image',
                controller.isUploadingPrimary.value,
                controller.primaryImageUrl.value.isNotEmpty,
                isDark,
              ),

            // Secondary Image Status
            if (controller.isSecondaryImageLoaded.value)
              _buildImageUploadStatus(
                'Outfit Image',
                controller.isUploadingSecondary.value,
                controller.secondaryImageUrl.value.isNotEmpty,
                isDark,
              ),
          ],
        ),
      );
    });
  }

  /// Build individual image upload status
  Widget _buildImageUploadStatus(String label, bool isUploading, bool isUploaded, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
      child: Row(
        children: [
          if (isUploading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isUploaded)
            Icon(Icons.check_circle, color: Colors.green, size: 16)
          else
            Icon(Icons.pending, color: Colors.orange, size: 16),

          const SizedBox(width: TSizes.sm),

          Expanded(
            child: Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: isDark ? TColors.grey : TColors.textSecondary,
              ),
            ),
          ),

          Text(
            isUploading
                ? 'Uploading...'
                : isUploaded
                ? 'Uploaded'
                : 'Pending',
            style: Get.textTheme.bodySmall?.copyWith(
              color: isUploading
                  ? Colors.blue
                  : isUploaded
                  ? Colors.green
                  : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced Selected Image Display with Upload Status
  Widget _buildSelectedImage(EcommerceWorkflowController controller, bool isDark, {required bool isPrimary}) {
    final imagePath = isPrimary ? controller.selectedImage.value : controller.secondaryImage.value;
    final isUploading = isPrimary ? controller.isUploadingPrimary.value : controller.isUploadingSecondary.value;
    final isUploaded = isPrimary
        ? controller.primaryImageUrl.value.isNotEmpty
        : controller.secondaryImageUrl.value.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
        border: Border.all(
          color: isUploaded
              ? Colors.green
              : isUploading
              ? Colors.blue
              : (isDark ? TColors.grey : TColors.borderPrimary),
          width: isUploaded || isUploading ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
            child: Image.file(
              File(imagePath),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),

          /// Upload overlay
          if (isUploading)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                color: Colors.black.withOpacity(0.5),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: TSizes.sm),
                    Text(
                      'Uploading to cloud...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          /// Success overlay
          if (isUploaded && !isUploading)
            Positioned(
              top: TSizes.sm,
              left: TSizes.sm,
              child: Container(
                padding: const EdgeInsets.all(TSizes.xs),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                ),
                child: const Icon(Icons.cloud_done, color: Colors.white, size: 16),
              ),
            ),

          /// Action buttons
          if (!isUploading)
            Positioned(
              top: TSizes.sm,
              right: TSizes.sm,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                ),
                child: IconButton(
                  onPressed: () => isPrimary
                      ? controller.clearPrimaryImage()
                      : controller.clearSecondaryImage(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),

          if (!isUploading)
            Positioned(
              bottom: TSizes.sm,
              right: TSizes.sm,
              child: Container(
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
                ),
                child: IconButton(
                  onPressed: () => _showImageSourceDialog(controller, isPrimary: isPrimary),
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ),
            ),

          /// Image label with upload status
          Positioned(
            bottom: TSizes.sm,
            left: TSizes.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
              decoration: BoxDecoration(
                color: isUploaded
                    ? Colors.green.withOpacity(0.9)
                    : (isDark ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.6)),
                borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPrimary ? 'Primary' : 'Secondary',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isUploaded) ...[
                    const SizedBox(width: TSizes.xs),
                    const Icon(Icons.check, color: Colors.white, size: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced Image Selector with Dark Mode
  Widget _buildImageSelector(EcommerceWorkflowController controller, bool isDark, {required bool isPrimary}) {
    return InkWell(
      onTap: () => _showImageSourceDialog(controller, isPrimary: isPrimary),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? TColors.grey : TColors.borderPrimary,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
          color: isDark ? TColors.dark : TColors.lightContainer,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: TColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              isPrimary ? 'Select Human Image' : 'Select Outfit Image',
              style: Get.textTheme.titleMedium?.copyWith(
                color: TColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TSizes.xs),
            Text(
              'Image will be automatically uploaded to cloud storage',
              style: Get.textTheme.bodySmall?.copyWith(
                color: isDark ? TColors.grey : TColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Custom Prompt Section with Dark Mode
  Widget _buildCustomPromptSection(EcommerceWorkflowController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Description',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TColors.white : TColors.textPrimary,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        TextField(
          controller: controller.promptController,
          onChanged: controller.updatePrompt,
          maxLines: 3,
          style: TextStyle(
            color: isDark ? TColors.white : TColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Enter description for the AI processing',
            labelStyle: TextStyle(
              color: isDark ? TColors.grey : TColors.textSecondary,
            ),
            hintText: 'E.g.: Have the woman in the image wear sleepwear and sit on the cabinet...',
            hintStyle: TextStyle(
              color: isDark ? TColors.grey.withOpacity(0.7) : TColors.textSecondary.withOpacity(0.7),
            ),
            prefixIcon: Icon(
              Icons.edit_note,
              color: isDark ? TColors.grey : TColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
              borderSide: BorderSide(
                color: isDark ? TColors.grey : TColors.borderPrimary,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
              borderSide: BorderSide(
                color: isDark ? TColors.grey : TColors.borderPrimary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
              borderSide: const BorderSide(color: TColors.primary),
            ),
            filled: true,
            fillColor: isDark ? TColors.dark : Colors.white,
          ),
        ),
      ],
    );
  }

  /// Processing Section with Enhanced Status
  Widget _buildProcessingSection(EcommerceWorkflowController controller, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Processing',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? TColors.white : TColors.textPrimary,
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        Obx(() => SizedBox(
          width: double.infinity,
          height: TSizes.buttonHeight * 3,
          child: ElevatedButton(
            onPressed: (controller.isProcessing.value || !controller.isWorkflowReady)
                ? null
                : controller.processWorkflow,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isWorkflowReady
                  ? TColors.primary
                  : (isDark ? TColors.grey.withOpacity(0.3) : TColors.grey.withOpacity(0.5)),
              foregroundColor: Colors.white,
              disabledBackgroundColor: isDark
                  ? TColors.grey.withOpacity(0.3)
                  : TColors.grey.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
              ),
              elevation: (controller.isProcessing.value || !controller.isWorkflowReady) ? 0 : TSizes.buttonElevation,
            ),
            child: controller.isProcessing.value
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: TSizes.md),
                Text(
                  'Processing AI Workflow...',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
                : controller.isAnyUploadInProgress
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload, color: Colors.white),
                const SizedBox(width: TSizes.sm),
                Text(
                  'Uploading Images...',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
                : controller.isWorkflowReady
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, color: Colors.white),
                const SizedBox(width: TSizes.sm),
                Text(
                  'Start AI Workflow',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, color: Colors.white70),
                const SizedBox(width: TSizes.sm),
                Text(
                  'Complete Setup First',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        )),

        // Workflow Status Info
        const SizedBox(height: TSizes.sm),
        Obx(() => Container(
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: isDark ? TColors.dark.withOpacity(0.5) : TColors.lightContainer,
            borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
          ),
          child: Text(
            controller.getWorkflowSummary(),
            style: Get.textTheme.bodySmall?.copyWith(
              color: isDark ? TColors.grey : TColors.textSecondary,
            ),
          ),
        )),
      ],
    );
  }

  /// Results Section with Dark Mode
  Widget _buildResultsSection(EcommerceWorkflowController controller, bool isDark) {
    return Obx(() {
      if (controller.combinedImagePath.value.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Results',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TColors.white : TColors.textPrimary,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          /// Result image
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
              border: Border.all(
                  color: isDark ? TColors.grey : TColors.borderPrimary
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
              child: Image.file(
                File(controller.combinedImagePath.value),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: TSizes.md),

          /// Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.saveProcessedImage,
                  icon: const Icon(Icons.download),
                  label: const Text('Save to Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TColors.primary,
                    side: const BorderSide(color: TColors.primary),
                    backgroundColor: isDark ? Colors.transparent : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TSizes.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.shareProcessedImage,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Result'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  /// Enhanced Image Source Dialog with Dark Mode
  void _showImageSourceDialog(EcommerceWorkflowController controller, {required bool isPrimary}) {
    final isDark = THelperFunctions.isDarkMode(Get.context!);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.lg),
        decoration: BoxDecoration(
          color: isDark ? TColors.dark : Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TSizes.borderRadiusLg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? TColors.grey : TColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: TSizes.lg),
            Text(
              isPrimary ? 'Select Primary Image' : 'Select Secondary Image',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? TColors.white : TColors.textPrimary,
              ),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              'Selected image will be uploaded to cloud storage',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: isDark ? TColors.grey : TColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TSizes.lg),

            ListTile(
              leading: const Icon(Icons.photo_library, color: TColors.primary),
              title: Text(
                'Photo Gallery',
                style: TextStyle(
                  color: isDark ? TColors.white : TColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Choose from your photos',
                style: TextStyle(
                  color: isDark ? TColors.grey : TColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Get.back();
                controller.selectImage(source: ImageSource.gallery, isPrimary: isPrimary);
              },
            ),

            ListTile(
              leading: const Icon(Icons.camera_alt, color: TColors.primary),
              title: Text(
                'Take New Photo',
                style: TextStyle(
                  color: isDark ? TColors.white : TColors.textPrimary,
                ),
              ),
              subtitle: Text(
                'Use camera to take a photo',
                style: TextStyle(
                  color: isDark ? TColors.grey : TColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Get.back();
                controller.selectImage(source: ImageSource.camera, isPrimary: isPrimary);
              },
            ),

            const SizedBox(height: TSizes.md),
          ],
        ),
      ),
    );
  }
}