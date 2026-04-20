import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  String selectedAddressType = 'Work'; // Work, Home, Other

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

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
    final userAsync = ref.watch(userProvider);

    userAsync.whenData((user) {
      if (user != null) {
        _fullNameController.text = user["name"] ?? "";
        _phoneController.text = user["phone"] ?? "";
        _houseController.text = user["address"] ?? "";
      }
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'Item\nSummary', true),
                  _buildStepConnector(isActive: true),
                  _buildStep(2, 'Delivery\nDetails', true),
                  _buildStepConnector(isActive: true),
                  _buildStep(3, 'Payment\nMethod', false),
                ],
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Delivery Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              // Address Type
              const Text(
                'Address Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildAddressTypeChip('Work', Icons.work),
                  const SizedBox(width: 12),
                  _buildAddressTypeChip('Home', Icons.home),
                  const SizedBox(width: 12),
                  _buildAddressTypeChip('Other', Icons.location_on),
                ],
              ),

              const SizedBox(height: 28),

              // Form Fields
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

              // City and State in Row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hintText: 'City',
                      controller: _cityController,
                      radius: 8,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      hintText: 'State',
                      controller: _stateController,
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

              const SizedBox(height: 40),

              // Next Button
              Center(
                child: SizedBox(
                  width: 100,

                  child: AppButton(
                    height: 40,
                    title: "Next",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.paymentPage);
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

  Widget _buildStep(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFE91E63) : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFFE91E63) : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildAddressTypeChip(String label, IconData icon) {
    bool isSelected = selectedAddressType == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedAddressType = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE91E63) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.button : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: text14(
                  color: isSelected
                      ? Colors.white
                      : Colors.grey[800] ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
