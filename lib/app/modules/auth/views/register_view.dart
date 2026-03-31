import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referralController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyController = TextEditingController();
  final _gstController = TextEditingController();
  final _dlController = TextEditingController(); // Drug License controller
  final _addressController = TextEditingController();
  final _selectedUserType = 'buyer'.obs;

  // Password visibility toggles
  final _isPasswordVisible = false.obs;
  final _isConfirmPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildUserTypeSelector(),
              const SizedBox(height: 32),
              _buildRegistrationForm(), // Removed Obx wrapper
              const SizedBox(height: 32),
              _buildRegisterButton(),
              const SizedBox(height: 24),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111261)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF111261).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_add_outlined,
            size: 32,
            color: Color(0xFF111261),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111261),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join MediSupply Pro today',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I want to register as a',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111261),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildUserTypeCard(
                'Buyer',
                Icons.shopping_cart_outlined,
                _selectedUserType.value == 'buyer',
                    () => _selectedUserType.value = 'buyer',
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _buildUserTypeCard(
                'Agency',
                Icons.store_outlined,
                _selectedUserType.value == 'vendor',
                    () => _selectedUserType.value = 'vendor',
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeCard(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0B630B).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0B630B) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0B630B) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF0B630B) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            prefixIcon: Icons.person_outline,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              if (value.length > 50) {
                return 'Name must not exceed 50 characters';
              }
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                return 'Name can only contain letters and spaces';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
              if (digitsOnly.length != 10) {
                return 'Phone number must be exactly 10 digits';
              }
              if (!RegExp(r'^[6-9]').hasMatch(digitsOnly)) {
                return 'Phone number must start with 6, 7, 8, or 9';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _referralController,
            label: 'Referral Code (Optional)',
            prefixIcon: Icons.card_giftcard_outlined,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.length < 4) {
                  return 'Referral code must be at least 4 characters if provided';
                }
                if (value.length > 15) {
                  return 'Referral code must not exceed 15 characters';
                }
                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                  return 'Referral code can only contain letters and numbers';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          Obx(() => _buildTextField(
            controller: _passwordController,
            label: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: !_isPasswordVisible.value,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF111261),
              ),
              onPressed: () => _isPasswordVisible.toggle(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              if (value.length > 32) {
                return 'Password must not exceed 32 characters';
              }
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Password must contain at least one uppercase letter';
              }
              if (!RegExp(r'[a-z]').hasMatch(value)) {
                return 'Password must contain at least one lowercase letter';
              }
              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Password must contain at least one number';
              }
              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                return 'Password must contain at least one special character';
              }
              return null;
            },
          )),
          const SizedBox(height: 16),

          Obx(() => _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            prefixIcon: Icons.lock_outline,
            obscureText: !_isConfirmPasswordVisible.value,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF111261),
              ),
              onPressed: () => _isConfirmPasswordVisible.toggle(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          )),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Business Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _companyController,
            label: 'Company / Business Name',
            prefixIcon: Icons.business_outlined,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter company name';
              }
              if (value.length < 2) {
                return 'Company name must be at least 2 characters';
              }
              if (value.length > 100) {
                return 'Company name must not exceed 100 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _dlController,
            label: 'Drug License Number',
            prefixIcon: Icons.medical_services_outlined,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            maxLength: 20,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Drug License number';
              }
              if (value.length < 5) {
                return 'Drug License number must be at least 5 characters';
              }
              if (value.length > 20) {
                return 'Drug License number must not exceed 20 characters';
              }
              // Basic DL format check (alphanumeric with optional hyphens)
              if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(value)) {
                return 'Drug License number can only contain letters, numbers, and hyphens';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _gstController,
            label: 'GST Number (Optional)',
            prefixIcon: Icons.numbers_outlined,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            maxLength: 15,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value.length != 15) {
                  return 'GST number must be exactly 15 characters if provided';
                }
                // Basic GST format check: 2 digits + 5 letters + 4 digits + 1 letter + 1 digit + 1 letter + 1 digit
                if (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$').hasMatch(value.toUpperCase())) {
                  return 'Please enter a valid GST number';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _addressController,
            label: 'Business Address',
            prefixIcon: Icons.location_on_outlined,
            maxLines: 3,
            keyboardType: TextInputType.streetAddress,
            maxLength: 200,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter business address';
              }
              if (value.length < 10) {
                return 'Please enter a complete address (minimum 10 characters)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF111261)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF111261)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF111261), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        counterText: '', // Hide counter text
        helperText: ' ',
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildRegisterButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : () {
          if (_formKey.currentState!.validate()) {
            FocusScope.of(Get.context!).unfocus();
            controller.register(
              name: _nameController.text.trim(),
              email: _emailController.text.trim().toLowerCase(),
              phone: _phoneController.text.trim().replaceAll(RegExp(r'\D'), ''),
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              userType: _selectedUserType.value,
              companyName: _companyController.text.trim(),
              gstNumber: _gstController.text.trim().isEmpty
                  ? null
                  : _gstController.text.trim().toUpperCase(),
              dlNumber: _dlController.text.trim(), // Add this to your AuthController register method
              businessAddress: _addressController.text.trim(),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B630B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: controller.isLoading.value
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Create Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ));
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: () {
            Get.offNamed('/login');
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: Color(0xFF111261),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}