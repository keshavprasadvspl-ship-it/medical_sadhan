// lib/app/modules/address/views/address_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/address_model.dart';
import '../controllers/address_controller.dart';

class AddressView extends GetView<AddressController> {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Address List or Add Form
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoading();
                }

                if (controller.isAddingAddress.value) {
                  return _buildAddEditForm();
                }

                return _buildAddressList();
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (!controller.isAddingAddress.value) {
          return FloatingActionButton.extended(
            onPressed: controller.startAddingAddress,
            backgroundColor: const Color(0xFF0B630B),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add New Address',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevation: 4,
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0B630B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0B630B)),
              onPressed: () {
                if (controller.isAddingAddress.value) {
                  controller.cancelForm();
                } else {
                  controller.navigateBackWithSelectedAddress();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => Text(
            controller.isAddingAddress.value
                ? (controller.isEditingAddress.value ? 'Edit Address' : 'Add New Address')
                : 'Delivery Addresses',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          )),
          const Spacer(),
          if (!controller.isAddingAddress.value)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0B630B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.check, color: Color(0xFF0B630B)),
                onPressed: controller.navigateBackWithSelectedAddress,
                tooltip: 'Use Selected Address',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return Obx(() {
      if (controller.addresses.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.addresses.length,
        itemBuilder: (context, index) {
          final address = controller.addresses[index];
          return _buildAddressCard(address);
        },
      );
    });
  }

  Widget _buildAddressCard(AddressModel address) {
    final isSelected = controller.selectedAddress.value?.id == address.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF0B630B)
              : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF0B630B).withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Header with Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Address Label Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.getAddressLabelColor(address.addressLabel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.getAddressLabelIcon(address.addressLabel),
                        size: 14,
                        color: controller.getAddressLabelColor(address.addressLabel),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.addressLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: controller.getAddressLabelColor(address.addressLabel),
                        ),
                      ),
                    ],
                  ),
                ),
                // Default Chip
                if (address.isDefaultShipping)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B630B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFF0B630B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Default',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0B630B),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Contact Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.contactPerson,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      address.contactPhone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (address.contactEmail != null && address.contactEmail!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.contactEmail!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Address Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Color(0xFF0B630B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.fullAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        if (address.landmark != null && address.landmark!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Landmark: ${address.landmark}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Address Actions
            Row(
              children: [
                // Select Button
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: () => controller.selectAddress(address),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.selectedAddress.value?.id == address.id
                          ? const Color(0xFF0B630B)
                          : Colors.white,
                      foregroundColor: controller.selectedAddress.value?.id == address.id
                          ? Colors.white
                          : const Color(0xFF111261),
                      elevation: controller.selectedAddress.value?.id == address.id ? 2 : 0,
                      side: BorderSide(
                        color: controller.selectedAddress.value?.id == address.id
                            ? const Color(0xFF0B630B)
                            : const Color(0xFF111261).withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      controller.selectedAddress.value?.id == address.id
                          ? 'Selected'
                          : 'Select',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ),

                const SizedBox(width: 8),

                // Edit Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: () => controller.startEditingAddress(address),
                    tooltip: 'Edit Address',
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Delete Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => controller.deleteAddress(address.id),
                    tooltip: 'Delete Address',
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Set Default Button
            if (!address.isDefaultShipping)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => controller.setDefaultAddress(address.id),
                  icon: const Icon(Icons.star_border, size: 16),
                  label: const Text('Set as Default'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0B630B),
                    backgroundColor: const Color(0xFF0B630B).withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEditForm() {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Label Selection Card
            _buildFormCard(
              title: 'Address Label',
              icon: Icons.label_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a label for this address *',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Row(
                    children: controller.addressLabels.map((label) {
                      final isSelected = controller.selectedAddressLabel.value == label;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => controller.selectedAddressLabel.value = label,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? controller.getAddressLabelColor(label).withOpacity(0.1)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? controller.getAddressLabelColor(label)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    controller.getAddressLabelIcon(label),
                                    size: 20,
                                    color: isSelected
                                        ? controller.getAddressLabelColor(label)
                                        : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? controller.getAddressLabelColor(label)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contact Details Card
            _buildFormCard(
              title: 'Contact Details',
              icon: Icons.contact_mail_outlined,
              child: Column(
                children: [
                  _buildFormField(
                    label: 'Full Name *',
                    hint: 'Enter your full name',
                    icon: Icons.person_outline,
                    controller: controller.contactPersonController,
                    validator: controller.validateFullName,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    label: 'Phone Number *',
                    hint: 'Enter 10-digit mobile number',
                    icon: Icons.phone_outlined,
                    controller: controller.contactPhoneController,
                    keyboardType: TextInputType.phone,
                    validator: controller.validatePhoneNumber,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    label: 'Email',
                    hint: 'Enter email address (optional)',
                    icon: Icons.email_outlined,
                    controller: controller.contactEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: controller.validateEmail,
                    required: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Address Details Card
            _buildFormCard(
              title: 'Address Details',
              icon: Icons.location_on_outlined,
              child: Column(
                children: [
                  _buildFormField(
                    label: 'Address Line 1 *',
                    hint: 'House no., Building, Street',
                    icon: Icons.home_outlined,
                    controller: controller.addressLine1Controller,
                    validator: controller.validateAddressLine1,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    label: 'Address Line 2',
                    hint: 'Area, Colony, Society',
                    icon: Icons.location_city_outlined,
                    controller: controller.addressLine2Controller,
                    required: false,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    label: 'Landmark',
                    hint: 'Nearby famous place',
                    icon: Icons.place_outlined,
                    controller: controller.landmarkController,
                    required: false,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'City *',
                          hint: 'City',
                          icon: Icons.location_city_outlined,
                          controller: controller.cityController,
                          validator: controller.validateCity,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          label: 'State *',
                          hint: 'State',
                          icon: Icons.map_outlined,
                          controller: controller.stateController,
                          validator: controller.validateState,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Pincode *',
                          hint: '6-digit pincode',
                          icon: Icons.pin_drop_outlined,
                          controller: controller.pincodeController,
                          keyboardType: TextInputType.number,
                          validator: controller.validatePincode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFormField(
                          label: 'Country *',
                          hint: 'Country',
                          icon: Icons.public_outlined,
                          controller: controller.countryController,
                          readOnly: true,
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Location and Default Options
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Use Current Location Button
                  Obx(() => controller.isGettingLocation.value
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF0B630B),
                      ),
                    ),
                  )
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.useCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Use Current Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF111261),
                        elevation: 0,
                        side: BorderSide(color: const Color(0xFF111261).withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  ),

                  const SizedBox(height: 16),

                  // Make Default Checkbox
                  Obx(() => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B630B).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: controller.makeDefault.value,
                            onChanged: (value) => controller.makeDefault.value = value ?? false,
                            activeColor: const Color(0xFF0B630B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Make this my default shipping address',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111261),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'This address will be selected by default for checkout',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save and Cancel Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.cancelForm,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B630B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      controller.isEditingAddress.value ? 'Update Address' : 'Save Address',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80), // Extra space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0B630B).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B630B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF0B630B), size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0B630B),
                  ),
                ),
              ],
            ),
          ),
          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool required = true,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator ?? (required ? _defaultValidator : null),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: const Color(0xFF0B630B), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0B630B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: const TextStyle(fontSize: 15),
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF0B630B),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF0B630B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 60,
                color: Color(0xFF0B630B),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Address Added',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111261),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first delivery address to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: controller.startAddingAddress,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B630B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),

                    shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
            ),
          elevation: 2,
        ),
      child: const Text(
        'Add New Address',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    ],
    ),
    ),
    );
  }
}