import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/checkout/address_req_model.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/address_res/address_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/address.provider.dart';

class EditAddAddressPage extends ConsumerStatefulWidget {
  final bool isEditing;
  final AddressRes? model;

  const EditAddAddressPage({super.key, required this.isEditing, this.model});

  @override
  ConsumerState<EditAddAddressPage> createState() => _EditAddAddressPageState();
}

class _EditAddAddressPageState extends ConsumerState<EditAddAddressPage> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditing && widget.model != null) {
        final data = widget.model!;

        // Set address type (Riverpod)
        ref.read(selectedAddressType.notifier).state = data.addressType ?? '';

        // Fill all fields
        _fullNameController.text = data.name ?? '';
        _phoneController.text = data.phone ?? '';
        _houseController.text = data.fullAddress ?? '';
        _cityController.text = data.city ?? '';
        _stateController.text = data.state ?? '';
        _pincodeController.text = data.pincode ?? '';
      }
    });
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
    final addressAsync = ref.watch(addressProvider);
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
              const SizedBox(height: 10),

              _buildAddressTypeRow(),

              const SizedBox(height: 15),

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
                    isLoading: addressAsync.isLoading,
                    height: 48,
                    title: widget.isEditing ? "Save Changes" : "Save Address",
                    onTap: () async {
                      if (_fullNameController.text.isEmpty ||
                          _phoneController.text.isEmpty ||
                          _houseController.text.isEmpty ||
                          _cityController.text.isEmpty ||
                          _stateController.text.isEmpty ||
                          _pincodeController.text.isEmpty) {
                        AppSnackbar.show(
                          context,
                          message: "Please fill all fields",
                          type: SnackBarType.error,
                        );
                        return;
                      }
                      if (!widget.isEditing) {
                        final addressType = ref.read(selectedAddressType);
                        final model = AddressReqModel(
                          addressType: addressType,
                          address: Address(
                            name: _fullNameController.text,
                            phone: _phoneController.text,
                            fullAddress: _houseController.text,
                            city: _cityController.text,
                            state: _stateController.text,
                            pincode: _pincodeController.text,
                          ),
                        );
                        await ref
                            .read(addressProvider.notifier)
                            .addAddress(model);
                      }
                      if (widget.isEditing) {
                        final id = widget.model?.id ?? '';
                        final addressType = ref.read(selectedAddressType);
                        final model = AddressReqModel(
                          addressType: addressType,
                          address: Address(
                            name: _fullNameController.text,
                            phone: _phoneController.text,
                            fullAddress: _houseController.text,
                            city: _cityController.text,
                            state: _stateController.text,
                            pincode: _pincodeController.text,
                          ),
                        );
                        await ref
                            .read(addressProvider.notifier)
                            .updateAddress(id, model);
                      }
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

  Widget _buildAddressTypeRow() {
    return Row(
      children: [
        _chip('Work', Icons.work),
        const SizedBox(width: 8),
        _chip('Home', Icons.home),
        const SizedBox(width: 8),
        _chip('Other', Icons.location_on),
      ],
    );
  }

  Widget _chip(String label, IconData icon) {
    final addressType = ref.watch(selectedAddressType);
    final selected = addressType == label.toLowerCase();

    return Expanded(
      child: GestureDetector(
        onTap: () =>
            ref.read(selectedAddressType.notifier).state = label.toLowerCase(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.button.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.button : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.button : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: text14(color: selected ? AppColors.button : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
