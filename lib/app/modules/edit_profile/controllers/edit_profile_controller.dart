import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/api_provider.dart';

class EditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text Controllers for user fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Text Controllers for business fields
  final businessNameController = TextEditingController();
  final businessTypeController = TextEditingController();
  final contactPersonController = TextEditingController();
  final designationController = TextEditingController();
  final gstNumberController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final establishmentYearController = TextEditingController();
  final totalBranchesController = TextEditingController();
  final businessRegistrationNumberController = TextEditingController();
  final averageMonthlyPurchaseController = TextEditingController();
  final creditLimitController = TextEditingController();
  final creditDaysController = TextEditingController();
  final preferredPaymentMethodController = TextEditingController();
  final buyerCategoryController = TextEditingController();
  final notesController = TextEditingController();

  final isLoading = false.obs;
  final isFetching = false.obs;
  int? userId;

  // Payment method options
  final List<String> paymentMethods = [
    'credit',
    'cash',
    'bank_transfer',
    'cheque',
    'online'
  ];

  // Buyer category options
  final List<String> buyerCategories = [
    'regular',
    'wholesaler',
    'retailer',
    'distributor',
    'institutional'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  // Always fetch fresh data from API
  Future<void> fetchProfileData() async {
    try {
      isFetching.value = true;

      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      final authToken = prefs.getString('auth_token');

      if (userDataString != null) {
        final userData = json.decode(userDataString);
        userId = userData['id'];

        // Set basic user info from prefs initially
        nameController.text = userData['name'] ?? '';
        emailController.text = userData['email'] ?? '';
        phoneController.text = userData['phone'] ?? '';
      }

      if (userId != null && authToken != null) {
        final apiService = Get.find<ApiService>();
        final response = await apiService.getBuyerProfile(
          userId: userId!,
          token: authToken,
        );

        if (response['status'] == true && response['data'] != null) {
          final userData = response['data']['user'];
          final buyerData = response['data']['buyer'];

          // Update user data
          if (userData != null) {
            nameController.text = userData['name'] ?? nameController.text;
            emailController.text = userData['email'] ?? emailController.text;
            phoneController.text = userData['phone'] ?? phoneController.text;
          }

          // Update business data
          if (buyerData != null) {
            businessNameController.text = buyerData['business_name'] ?? '';
            businessTypeController.text = buyerData['business_type'] ?? '';
            contactPersonController.text = buyerData['contact_person'] ?? '';
            designationController.text = buyerData['designation'] ?? '';
            gstNumberController.text = buyerData['gst_number'] ?? '';
            licenseNumberController.text = buyerData['license_number'] ?? '';
            establishmentYearController.text = buyerData['establishment_year']?.toString() ?? '';
            totalBranchesController.text = buyerData['total_branches']?.toString() ?? '';
            businessRegistrationNumberController.text = buyerData['business_registration_number'] ?? '';
            averageMonthlyPurchaseController.text = buyerData['average_monthly_purchase']?.toString() ?? '';
            creditLimitController.text = buyerData['credit_limit']?.toString() ?? '';
            creditDaysController.text = buyerData['credit_days']?.toString() ?? '';
            preferredPaymentMethodController.text = buyerData['preferred_payment_method'] ?? '';
            buyerCategoryController.text = buyerData['buyer_category'] ?? '';
            notesController.text = buyerData['notes'] ?? '';
          }
        }
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
    } finally {
      isFetching.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final apiService = Get.find<ApiService>();
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      // Prepare data according to API payload requirements
      final Map<String, dynamic> profileData = {
        "user_id": userId,
        "name": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "business_name": businessNameController.text,
        "business_type": businessTypeController.text,
        "contact_person": contactPersonController.text,
        "designation": designationController.text,
        "gst_number": gstNumberController.text,
        "license_number": licenseNumberController.text,
        "establishment_year": establishmentYearController.text.isNotEmpty
            ? int.tryParse(establishmentYearController.text)
            : null,
        "total_branches": totalBranchesController.text.isNotEmpty
            ? int.tryParse(totalBranchesController.text)
            : null,
        "business_registration_number": businessRegistrationNumberController.text,
        "average_monthly_purchase": averageMonthlyPurchaseController.text.isNotEmpty
            ? double.tryParse(averageMonthlyPurchaseController.text)
            : null,
        "credit_limit": creditLimitController.text.isNotEmpty
            ? double.tryParse(creditLimitController.text)
            : null,
        "credit_days": creditDaysController.text.isNotEmpty
            ? int.tryParse(creditDaysController.text)
            : null,
        "preferred_payment_method": preferredPaymentMethodController.text,
        "buyer_category": buyerCategoryController.text,
        "notes": notesController.text,
      };

      // Remove null values
      profileData.removeWhere((key, value) => value == null);

      final response = await apiService.saveBuyerProfile(
        userId: userId!,
        data: profileData,
        token: authToken,
      );

      if (response['status'] == true) {
        // Update user data in SharedPreferences
        await prefs.setString('user_data', json.encode({
          'id': userId,
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
        }));

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green[700],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        Get.back();
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Update failed',
          backgroundColor: Colors.red[700],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Dispose all controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    businessTypeController.dispose();
    contactPersonController.dispose();
    designationController.dispose();
    gstNumberController.dispose();
    licenseNumberController.dispose();
    establishmentYearController.dispose();
    totalBranchesController.dispose();
    businessRegistrationNumberController.dispose();
    averageMonthlyPurchaseController.dispose();
    creditLimitController.dispose();
    creditDaysController.dispose();
    preferredPaymentMethodController.dispose();
    buyerCategoryController.dispose();
    notesController.dispose();
    super.onClose();
  }
}