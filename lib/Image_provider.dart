import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImageState extends StateNotifier<File?> {
  ImageState() : super(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      state = File(pickedFile.path);
    }
  }

  Future<void> captureImageWithCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      state = File(pickedFile.path);
    }
  }

  void clearImage() {
    state = null;
  }
}

// Provider to manage the image state
final imageProvider = StateNotifierProvider<ImageState, File?>((ref) {
  return ImageState();
});
