import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

// Image state
final profileImageProvider = StateProvider<File?>((ref) => null);

// Image picker instance
final imagePickerProvider = Provider((ref) => ImagePicker());

// Pick image function
class ProfileImageController {
  static Future<void> pickImage(WidgetRef ref) async {
    final picker = ref.read(imagePickerProvider);

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      ref.read(profileImageProvider.notifier).state = File(pickedFile.path);
    }
  }
}
