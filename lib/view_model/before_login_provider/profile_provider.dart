import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

// Image state
final profileImageProvider = StateProvider<File?>((ref) => null);

// Image picker instance
final imagePickerProvider = Provider((ref) => ImagePicker());

// Pick image function
class ProfileImageController {
  static Future<void> pickImage(
    WidgetRef ref, {
    ImageSource source = ImageSource.gallery,
  }) async {
    final picker = ref.read(imagePickerProvider);

    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      ref.read(profileImageProvider.notifier).state = File(pickedFile.path);
    }
  }

  static void showImagePickerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  pickImage(ref, source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  pickImage(ref, source: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
