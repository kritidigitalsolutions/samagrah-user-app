import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'dart:io';

import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? profileImageUrl;
  String? userId;

  // Example initial data
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final user = await AuthLocalstorageService.getUser();

      if (user != null) {
        _nameController.text = user['name'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _addressController.text = user['address'] ?? '';
        profileImageUrl = user['profileImage']; // ✅ important
        userId = user['id'];
        setState(() {});
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateProfileProvider);
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],

                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (profileImageUrl != null &&
                                profileImageUrl!.isNotEmpty)
                          ? NetworkImage(getFullImageUrl(profileImageUrl!))
                          : null,

                      child:
                          (_imageFile == null &&
                              (profileImageUrl == null ||
                                  profileImageUrl!.isEmpty))
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Name
              AppTextField(
                radius: 8,
                prefixIcon: Icon(Icons.person),
                controller: _nameController,
                hintText: 'Full Name',
              ),

              const SizedBox(height: 16),

              // Email
              AppTextField(
                radius: 8,
                prefixIcon: Icon(Icons.email),
                controller: _emailController,
                hintText: 'enter email',
              ),
              const SizedBox(height: 16),

              // number
              NumberTextField(
                radius: 8,
                prefixIcon: Icon(Icons.call),
                controller: _phoneController,
                hintText: 'Enter your phone number',
              ),

              const SizedBox(height: 16),

              AppTextField(
                radius: 8,
                maxline: 3,
                prefixIcon: Icon(Icons.location_on_outlined),
                controller: _addressController,
                hintText: 'Enter your Address',
              ),

              const SizedBox(height: 40),

              // Save Button
              AppButton(
                radius: 8,
                title: updateState.isLoading ? "Saving..." : "Save Changes",
                onTap: updateState.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        await ref
                            .read(updateProfileProvider.notifier)
                            .updateProfile(
                              userId: userId ?? '',
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              address: _addressController.text.trim(),
                              imageFile: _imageFile,
                            );

                        final state = ref.read(updateProfileProvider);

                        state.when(
                          data: (_) {
                            AppSnackbar.show(
                              context,
                              message: 'Profile updated successfully!',
                              type: SnackBarType.success,
                            );
                            Navigator.pop(context);
                          },
                          loading: () {},
                          error: (e, _) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          },
                        );
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

String getFullImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  // ✅ If already full URL → return as it is
  if (url.startsWith('http')) {
    return url;
  }

  // ✅ Else attach base URL
  return "http://192.168.1.40:8000/$url";
}
