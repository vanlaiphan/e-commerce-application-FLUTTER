import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

class AIRepository extends GetxController {
  static AIRepository get instance => Get.find();

  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload AI image to Firebase Storage
  Future<String> uploadAIImage({
    required File imageFile,
    required String userId,
    required String imageType, // 'primary' or 'secondary'
    String? customName,
  }) async {
    try {
      // Read file as bytes
      final Uint8List fileData = await imageFile.readAsBytes();

      // Generate unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(imageFile.path);
      final String filename = customName ?? '${imageType}_${timestamp}${extension}';

      // Create storage path: AI/userId/filename
      final String storagePath = 'AI/$userId/$filename';

      // Reference to the storage location
      final Reference ref = _storage.ref(storagePath);

      // Determine MIME type
      String mimeType = 'image/jpeg';
      if (extension.toLowerCase() == '.png') {
        mimeType = 'image/png';
      } else if (extension.toLowerCase() == '.jpg' || extension.toLowerCase() == '.jpeg') {
        mimeType = 'image/jpeg';
      }

      // Upload file using Uint8List
      final UploadTask uploadTask = ref.putData(
          fileData,
          SettableMetadata(contentType: mimeType)
      );

      // Wait for the upload to complete
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

      // Get download URL
      final String downloadURL = await snapshot.ref.getDownloadURL();

      // Save metadata to Firestore
      await _saveImageMetadata(
        userId: userId,
        filename: filename,
        downloadUrl: downloadURL,
        storagePath: storagePath,
        imageType: imageType,
        fileSize: fileData.length,
        mimeType: mimeType,
      );

      return downloadURL;

    } on FirebaseException catch (e) {
      throw 'Firebase Error: ${e.message ?? 'Unknown error occurred'}';
    } on SocketException catch (e) {
      throw 'Network Error: ${e.message}';
    } on PlatformException catch (e) {
      throw 'Platform Error: ${e.message ?? 'Unknown error occurred'}';
    } catch (e) {
      throw 'Upload Error: ${e.toString()}';
    }
  }

  /// Save image metadata to Firestore
  Future<void> _saveImageMetadata({
    required String userId,
    required String filename,
    required String downloadUrl,
    required String storagePath,
    required String imageType,
    required int fileSize,
    required String mimeType,
  }) async {
    try {
      final Map<String, dynamic> metadata = {
        'userId': userId,
        'filename': filename,
        'downloadUrl': downloadUrl,
        'storagePath': storagePath,
        'imageType': imageType, // 'primary' or 'secondary'
        'fileSize': fileSize,
        'mimeType': mimeType,
        'folder': 'AI',
        'mediaCategory': 'ai',
        'uploadedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('AIImages').add(metadata);
    } catch (e) {
      throw 'Metadata Save Error: ${e.toString()}';
    }
  }

  /// Get user's AI images
  Future<List<Map<String, dynamic>>> getUserAIImages(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('AIImages')
          .where('userId', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })
          .toList();
    } on FirebaseException catch (e) {
      throw 'Firestore Error: ${e.message ?? 'Unknown error occurred'}';
    } catch (e) {
      throw 'Fetch Error: ${e.toString()}';
    }
  }

  /// Delete AI image
  Future<void> deleteAIImage({
    required String imageId,
    required String storagePath,
  }) async {
    try {
      // Delete from Storage
      await _storage.ref(storagePath).delete();

      // Delete from Firestore
      await _firestore.collection('AIImages').doc(imageId).delete();

    } on FirebaseException catch (e) {
      throw 'Delete Error: ${e.message ?? 'Unknown error occurred'}';
    } catch (e) {
      throw 'Delete Error: ${e.toString()}';
    }
  }

  /// Upload multiple images (batch upload)
  Future<List<String>> uploadMultipleAIImages({
    required List<File> imageFiles,
    required String userId,
    String imageType = 'batch',
  }) async {
    List<String> downloadUrls = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final String customName = '${imageType}_${i + 1}_${DateTime.now().millisecondsSinceEpoch}';
        final String downloadUrl = await uploadAIImage(
          imageFile: imageFiles[i],
          userId: userId,
          imageType: imageType,
          customName: customName,
        );
        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      throw 'Batch Upload Error: ${e.toString()}';
    }
  }
}