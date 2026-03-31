import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Business Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor:Color(0xFF0B630B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: SafeArea(
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Card
                  _buildInfoCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    children: [
                      _buildTextField(
                        label: "Full Name",
                        controller: controller.nameController,
                        icon: Icons.person_outline,
                        required: true,
                        maxLength: 255,
                        textCapitalization: TextCapitalization.words,
                      ),
                      _buildTextField(
                        label: "Email",
                        controller: controller.emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                        maxLength: 255,
                      ),
                      _buildTextField(
                        label: "Phone",
                        controller: controller.phoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        required: true,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Business Information Card
                  _buildInfoCard(
                    title: 'Business Information',
                    icon: Icons.business_outlined,
                    children: [
                      _buildTextField(
                        label: "Business Name",
                        controller: controller.businessNameController,
                        icon: Icons.business_outlined,
                        required: true,
                        maxLength: 255,
                        textCapitalization: TextCapitalization.words,
                      ),
                      _buildTextField(
                        label: "Business Type",
                        controller: controller.businessTypeController,
                        icon: Icons.category_outlined,
                        maxLength: 255,
                        textCapitalization: TextCapitalization.words,
                      ),
                      _buildTextField(
                        label: "Contact Person",
                        controller: controller.contactPersonController,
                        icon: Icons.person_outline,
                        maxLength: 255,
                        textCapitalization: TextCapitalization.words,
                      ),
                      _buildTextField(
                        label: "Designation",
                        controller: controller.designationController,
                        icon: Icons.work_outline,
                        maxLength: 255,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Registration Details Card
                  _buildInfoCard(
                    title: 'Registration Details',
                    icon: Icons.description_outlined,
                    children: [
                      _buildTextField(
                        label: "GST Number",
                        controller: controller.gstNumberController,
                        icon: Icons.numbers_outlined,
                        maxLength: 15,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                        ],
                      ),
                      _buildTextField(
                        label: "License Number",
                        controller: controller.licenseNumberController,
                        icon: Icons.description_outlined,
                        maxLength: 100,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      _buildTextField(
                        label: "Business Registration Number",
                        controller: controller.businessRegistrationNumberController,
                        icon: Icons.assignment_outlined,
                        maxLength: 100,
                      ),
                    ],
                  ),


                  const SizedBox(height: 20),

                  // Additional Details Card
                  _buildInfoCard(
                    title: 'Additional Details',
                    icon: Icons.info_outline,
                    children: [
                      _buildTextField(
                        label: "Establishment Year",
                        controller: controller.establishmentYearController,
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                      ),
                      _buildTextField(
                        label: "Total Branches",
                        controller: controller.totalBranchesController,
                        icon: Icons.business_outlined,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      _buildTextField(
                        label: "Additional Notes",
                        controller: controller.notesController,
                        icon: Icons.note_outlined,
                        maxLines: 3,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Submit Button
                  Obx(() => Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF0B630B).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0B630B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.updateProfile,
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                          : const Text(
                        "Update Business Profile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              color: Color(0xFF0B630B).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF0B630B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Color(0xFF0B630B),
                    size: 20,
                  ),
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
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? customValidator,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        validator: (value) {
          // Required field validation
          if (required && (value == null || value.isEmpty)) {
            return '$label is required';
          }

          // Custom validator if provided
          if (customValidator != null) {
            return customValidator(value);
          }

          // Field-specific validations
          if (value != null && value.isNotEmpty) {
            // Email validation
            if (keyboardType == TextInputType.emailAddress) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
            }

            // Phone validation
            if (keyboardType == TextInputType.phone) {
              final phoneRegex = RegExp(r'^[0-9]{10,15}$');
              if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
                return 'Please enter a valid phone number';
              }
            }

            // GST validation (15 characters: 2 letters + 10 digits + 3 letters)
            if (label.contains('GST')) {
              final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$');
              if (!gstRegex.hasMatch(value.toUpperCase())) {
                return 'Please enter a valid GST number';
              }
            }

            // Year validation
            if (label.contains('Year')) {
              final year = int.tryParse(value);
              final currentYear = DateTime.now().year;
              if (year == null || year < 1900 || year > currentYear) {
                return 'Please enter a valid year (1900-$currentYear)';
              }
            }

            // Number validation for numeric fields
            if (keyboardType == TextInputType.number && label.contains('Branches')) {
              final number = int.tryParse(value);
              if (number == null || number < 0) {
                return 'Please enter a valid number';
              }
            }
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF0B630B), size: 20)
              : null,
          counterText: maxLength != null ? '' : null, // Hide default counter if using maxLength
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
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
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}