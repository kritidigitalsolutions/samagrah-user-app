import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/checkout/address_req_model.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/address.provider.dart';

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.listen(addressProvider, (prev, next) {
        final list = next.value?.addresses?.data?.addresses ?? [];

        if (list.isEmpty) {
          ref.read(showFormProvider.notifier).state = true;
        }
      });
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

  void clearAll() {
    // Clear text fields
    _fullNameController.clear();
    _phoneController.clear();
    _houseController.clear();
    _cityController.clear();
    _stateController.clear();
    _pincodeController.clear();

    // Reset address type
    ref.read(selectedAddressType.notifier).state = 'work';

    // Reset checkbox (save address)
    ref.read(saveAddressProvider.notifier).state = false;

    // Reset edit mode
    ref.read(isEditProvider.notifier).state = false;

    // Optional: clear selected address (important for edit case)
    // ref.read(addressProvider.notifier).selectAddress(null);
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = ref.watch(saveAddressProvider);
    final addressAsync = ref.watch(addressProvider);
    final showForm = ref.watch(showFormProvider);
    final isEditing = ref.watch(isEditProvider);

    final list = addressAsync.value?.addresses?.data?.addresses ?? [];
    final shouldShowForm = showForm || list.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,

      // 🔥 Sticky Bottom Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            title: isEditing ? "Save Address" : "Continue to Payment",
            onTap: () {
              _handleNext(shouldShowForm);
            },
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepper(),

              const SizedBox(height: 24),

              Text(
                "Delivery Details",
                style: text20(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // ================= SAVED ADDRESSES =================
              addressAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Error: $e"),
                data: (data) {
                  final list = data.addresses?.data?.addresses ?? [];

                  if (list.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Saved Addresses",
                        style: text18(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 12),

                      ...list.map((addr) {
                        final isSelected = data.selectedAddress?.id == addr.id;

                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(addressProvider.notifier)
                                .selectAddress(addr);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.button
                                    : AppColors.grey200,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: AppColors.button,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            addr.name ?? "",
                                            style: text16(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (addr.isDefault == true)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "DEFAULT",
                                                style: text10(
                                                  color: AppColors.green,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${addr.fullAddress}, ${addr.city}",
                                        style: text14(color: AppColors.grey700),
                                      ),
                                      Text(
                                        "${addr.state} - ${addr.pincode}",
                                        style: text14(color: AppColors.grey700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        addr.phone ?? "",
                                        style: text13(color: AppColors.grey),
                                      ),

                                      const SizedBox(height: 10),

                                      /// 🔥 ACTION BUTTONS (Better Placement)
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AppIconButton(
                                        size: 32,
                                        iconSize: 18,
                                        icon: Icons.edit,
                                        onTap: () {
                                          // 🔥 Fill form for editing
                                          _fullNameController.text =
                                              addr.name ?? "";
                                          _phoneController.text =
                                              addr.phone ?? "";
                                          _houseController.text =
                                              addr.fullAddress ?? "";
                                          _cityController.text =
                                              addr.city ?? "";
                                          _stateController.text =
                                              addr.state ?? "";
                                          _pincodeController.text =
                                              addr.pincode ?? "";
                                          ref
                                                  .read(
                                                    showFormProvider.notifier,
                                                  )
                                                  .state =
                                              true;
                                          ref
                                                  .read(isEditProvider.notifier)
                                                  .state =
                                              true;

                                          ref
                                                  .read(
                                                    selectedAddressType
                                                        .notifier,
                                                  )
                                                  .state =
                                              addr.addressType ?? "home";
                                          ref
                                                  .read(
                                                    addressIdProvider.notifier,
                                                  )
                                                  .state =
                                              addr.id ?? '';
                                          // store selected for update
                                          ref
                                              .read(addressProvider.notifier)
                                              .selectAddress(addr);
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      AppIconButton(
                                        size: 32,
                                        iconSize: 18,
                                        icon: Icons.delete,
                                        iconColor: AppColors.button,
                                        onTap: () async {
                                          await ref
                                              .read(addressProvider.notifier)
                                              .deleteAddress(addr.id ?? "");

                                          if (context.mounted) {
                                            AppSnackbar.show(
                                              context,
                                              message: "Address deleted",
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 20),

                      _buildDivider(),
                    ],
                  );
                },
              ),

              if (!shouldShowForm) ...[
                AppButton(
                  title: "Add New Address",
                  onTap: () {
                    ref.read(showFormProvider.notifier).state = true;
                    ref.read(isEditProvider.notifier).state = false;
                    _fullNameController.clear();
                    _phoneController.clear();
                    _houseController.clear();
                    _cityController.clear();
                    _stateController.clear();
                    _pincodeController.clear();
                  },
                ),
              ] else ...[
                Text(
                  isEditing ? "Edit Address" : "Add New Address",
                  style: text18(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                _buildAddressTypeRow(),

                const SizedBox(height: 20),

                _buildCard(
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _fullNameController,
                        hintText: 'Full Name',
                      ),
                      const SizedBox(height: 12),
                      NumberTextField(
                        controller: _phoneController,
                        hintText: 'Phone Number',
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _houseController,
                        hintText: 'House / Building',
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _cityController,
                              hintText: 'City',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _stateController,
                              hintText: 'State',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      NumberTextField(
                        controller: _pincodeController,
                        hintText: 'Pincode',
                      ),

                      const SizedBox(height: 12),
                      if (!isEditing)
                        Row(
                          children: [
                            Checkbox(
                              value: isSaved,
                              onChanged: (val) {
                                ref.read(saveAddressProvider.notifier).state =
                                    val ?? false;
                              },
                            ),
                            Expanded(
                              child: Text(
                                "Save this address for future orders",
                                style: text14(color: AppColors.grey),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= NEXT LOGIC =================
  void _handleNext(bool showForm) async {
    final isEdit = ref.read(isEditProvider);
    final addressType = ref.read(selectedAddressType);
    final addressId = ref.read(addressIdProvider);
    if (isEdit) {
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

      await ref.read(addressProvider.notifier).updateAddress(addressId, model);
      ref.read(showFormProvider.notifier).state = false;
      ref.read(isEditProvider.notifier).state = false;
      clearAll();
    } else {
      final selected = ref.read(addressProvider).value?.selectedAddress;
      final save = ref.read(saveAddressProvider);

      // ✅ If already selected → continue
      if (selected != null) {
        ref.read(storeAddressProvider.notifier).state = Address(
          name: selected.name ?? "",
          phone: selected.phone ?? "",
          fullAddress: selected.fullAddress ?? "",
          city: selected.city ?? "",
          state: selected.state ?? "",
          pincode: selected.pincode ?? "",
        );

        ref.read(showFormProvider.notifier).state = false;
        ref.read(isEditProvider.notifier).state = false;

        clearAll();

        Navigator.pushNamed(context, AppRoutes.paymentPage);
        return;
      }

      if (!showForm) {
        clearAll();
        AppSnackbar.show(
          context,
          message: "Please select your address",
          type: SnackBarType.error,
        );
        return;
      }

      // ✅ If adding new address
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

      try {
        // 🔥 if "save address" checked → call API
        if (save) {
          await ref.read(addressProvider.notifier).addAddress(model);
        }

        // store locally
        ref.read(storeAddressProvider.notifier).state = Address(
          name: model.address.name,
          phone: model.address.phone,
          fullAddress: model.address.fullAddress,
          city: model.address.city,
          state: model.address.state,
          pincode: model.address.pincode,
        );

        if (context.mounted) {
          ref.read(showFormProvider.notifier).state = false;
          ref.read(isEditProvider.notifier).state = false;
          Navigator.pushNamed(context, AppRoutes.paymentPage);
        }
      } catch (e) {
        AppSnackbar.show(
          context,
          message: "Something went wrong",
          type: SnackBarType.error,
        );
      }
    }
  }

  // ================= UI HELPERS =================

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(1, 'Item\nSummary', true),
        _buildStepConnector(isActive: true),
        _buildStep(2, 'Delivery\nAddress', true),
        _buildStepConnector(isActive: true),
        _buildStep(3, 'Payment\nMethod', true),
      ],
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
            color: isActive ? AppColors.button : AppColors.grey300,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: text14(
                color: isActive ? AppColors.white : AppColors.grey600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: text10(color: isActive ? AppColors.black : AppColors.grey600),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppColors.button : AppColors.grey300,
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("OR"),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}
