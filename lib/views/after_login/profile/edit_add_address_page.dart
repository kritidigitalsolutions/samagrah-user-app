import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_textfields.dart';

class EditAddAddressPage extends StatefulWidget {
  final bool isEditing;
  final String? initialAddress;

  const EditAddAddressPage({
    super.key,
    required this.isEditing,
    this.initialAddress,
  });

  @override
  State<EditAddAddressPage> createState() => _EditAddAddressPageState();
}

class _EditAddAddressPageState extends State<EditAddAddressPage> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialAddress != null) {
      _houseController.text = widget.initialAddress ?? '';
      // You can add more parsing logic here if needed
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.isEditing ? 'Edit Address' : 'Add New Address',
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              AppTextField(
                controller: _fullNameController,
                hintText: 'Enter your full name',
                radius: 8,
              ),

              const SizedBox(height: 16),
              NumberTextField(
                controller: _phoneController,
                hintText: 'Phone Number',
                radius: 8,
              ),

              const SizedBox(height: 16),
              AppTextField(
                controller: _houseController,
                hintText: 'House / Plot / Building',
                radius: 8,
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _cityController,
                      hintText: 'City',
                      radius: 8,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      hintText: 'State',
                      radius: 8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              NumberTextField(
                controller: _pincodeController,
                hintText: 'Pincode',
                radius: 8,
              ),

              const SizedBox(height: 50),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    height: 48,
                    title: widget.isEditing ? "Save Changes" : "Save Address",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address saved successfully!'),
                        ),
                      );
                      Navigator.pop(context); // Go back to Saved Addresses
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
