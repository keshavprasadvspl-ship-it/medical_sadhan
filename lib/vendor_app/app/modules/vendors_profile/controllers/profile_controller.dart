import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../app/data/providers/api_endpoints.dart';
import '../../../../../app/routes/app_pages.dart';

class VendorsProfileController extends GetxController {
  var isLoading = false.obs;
  var isEditing = false.obs;
  var isSaving = false.obs;

  // Vendor ID
  late SharedPreferences _prefs;
  final userId = 0.obs;
  final vendorId = 0.obs;

  // User profile data
  var name = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var isActive = false.obs;
  var isVerified = false.obs;
  // var isEditing = false.obs;

  // Vendor details
  var businessName = ''.obs;
  var businessType = ''.obs;
  var contactPerson = ''.obs;
  var designation = ''.obs;
  var gstNumber = ''.obs;
  var companyRegistrationNumber = ''.obs;
  var yearOfEstablishment = ''.obs;
  var drugLicenseNumber = ''.obs;
  var averageMonthlySales = 0.0.obs;
  var vendorCategory = ''.obs;
  var vendorRating = 0.0.obs;
  var successfulOrders = 0.obs;
  var logoUrl = ''.obs;
  var notes = ''.obs;

  // Bank details (if available in future)
  var accountHolderName = ''.obs;
  var accountNumber = ''.obs;
  var bankName = ''.obs;
  var ifscCode = ''.obs;
  var upiId = ''.obs;

  // Statistics (from dashboard)
  var totalOrders = 0.obs;
  var totalProducts = 0.obs;
  var totalRevenue = 0.0.obs;
  var pendingOrders = 0.obs;

  // Controllers for edit mode
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final businessNameController = TextEditingController();
  final businessTypeController = TextEditingController();
  final contactPersonController = TextEditingController();
  final designationController = TextEditingController();
  final gstNumberController = TextEditingController();
  final companyRegistrationNumberController = TextEditingController();
  final yearOfEstablishmentController = TextEditingController();
  final drugLicenseNumberController = TextEditingController();
  final averageMonthlySalesController = TextEditingController();
  final vendorCategoryController = TextEditingController();
  final notesController = TextEditingController();


  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void onInit() {
    super.onInit();
    initializePrefs();
  }

  Future<void> initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadUserData();
    fetchProfileData();
    fetchDashboardStats();
  }

  void loadUserData() {
    final userDataString = _prefs.getString('user_data');
    if (userDataString != null && userDataString.isNotEmpty) {
      final userData = json.decode(userDataString);
      userId.value = int.tryParse(userData['id']?.toString() ?? '0') ?? 0;
    }
  }

  void initializeControllers() {
    // Sync controllers with new data
    nameController.text = name.value;
    emailController.text = email.value;
    phoneController.text = phone.value;
    businessNameController.text = businessName.value;
    businessTypeController.text = businessType.value;
    contactPersonController.text = contactPerson.value;
    designationController.text = designation.value;
    gstNumberController.text = gstNumber.value;
    companyRegistrationNumberController.text = companyRegistrationNumber.value;
    yearOfEstablishmentController.text = yearOfEstablishment.value;
    drugLicenseNumberController.text = drugLicenseNumber.value;
    averageMonthlySalesController.text = averageMonthlySales.value.toString();
    vendorCategoryController.text = vendorCategory.value;
    notesController.text = notes.value;
  }

  Future<void> fetchProfileData() async {
    if (userId.value == 0) return;

    try {
      isLoading.value = true;

      final uri = Uri.parse('${ApiEndpoints.baseUrl}/vendor/profile')
          .replace(queryParameters: {'user_id': userId.value.toString()});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          final data = jsonData['data'];

          // User details
          final userDetails = data['user_details'];
          name.value = userDetails['name'] ?? '';
          email.value = userDetails['email'] ?? '';
          phone.value = userDetails['phone'] ?? '';
          isActive.value = userDetails['is_active'] ?? false;
          isVerified.value = userDetails['is_verified'] ?? false;

          // Vendor details
          final vendorDetails = data['vendor_details'];
          if (vendorDetails != null) {
            vendorId.value = vendorDetails['vendor_id'] ?? 0;
            businessName.value = vendorDetails['business_name'] ?? '';
            businessType.value = vendorDetails['business_type'] ?? '';
            contactPerson.value = vendorDetails['contact_person'] ?? '';
            designation.value = vendorDetails['designation'] ?? '';
            gstNumber.value = vendorDetails['gst_number'] ?? '';
            companyRegistrationNumber.value = vendorDetails['company_registration_number'] ?? '';
            yearOfEstablishment.value = vendorDetails['year_of_establishment']?.toString() ?? '';
            drugLicenseNumber.value = vendorDetails['drug_license_number'] ?? '';
            averageMonthlySales.value =
                double.tryParse(vendorDetails['average_monthly_sales']?.toString() ?? '0') ?? 0.0;
            vendorCategory.value = vendorDetails['vendor_category'] ?? '';
            vendorRating.value =  double.tryParse(vendorDetails['vendor_rating'] ?? '0')?? 0.0;
            successfulOrders.value = vendorDetails['successful_orders'] ?? 0;
            logoUrl.value = vendorDetails['logo_url'] ?? '';
            notes.value = vendorDetails['notes'] ?? '';
          }

          // Initialize controllers with fetched data
          initializeControllers();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDashboardStats() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/vendor-dashboard/stats')
          .replace(queryParameters: {'vendor_id': vendorId.value.toString()});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          final data = jsonData['data'];

          totalOrders.value = data['orders']['total'] ?? 0;
          pendingOrders.value = data['orders']['pending'] ?? 0;
          totalRevenue.value = (data['revenue']['total'] ?? 0).toDouble();
          totalProducts.value = data['products']['total'] ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching dashboard stats: $e');
    }
  }

  void toggleEdit() {
    if (isEditing.value) {
      // Save changes when exiting edit mode
      saveProfile();
    } else {
      isEditing.value = true;
    }
  }

  void cancelEdit() {
    // Reset controllers to original values
    nameController.text = name.value;
    emailController.text = email.value;
    phoneController.text = phone.value;
    businessNameController.text = businessName.value;
    businessTypeController.text = businessType.value;
    contactPersonController.text = contactPerson.value;
    designationController.text = designation.value;
    gstNumberController.text = gstNumber.value;
    companyRegistrationNumberController.text = companyRegistrationNumber.value;
    yearOfEstablishmentController.text = yearOfEstablishment.value;
    drugLicenseNumberController.text = drugLicenseNumber.value;
    averageMonthlySalesController.text = averageMonthlySales.value.toString();
    vendorCategoryController.text = vendorCategory.value;
    notesController.text = notes.value;

    isEditing.value = false;
  }

  Future<void> saveProfile() async {
    try {
      isSaving.value = true;

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/vendor/profile/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId.value,
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'business_name': businessNameController.text,
          'business_type': businessTypeController.text,
          'contact_person': contactPersonController.text,
          'designation': designationController.text,
          'gst_number': gstNumberController.text,
          'company_registration_number': companyRegistrationNumberController.text,
          'year_of_establishment': int.tryParse(yearOfEstablishmentController.text),
          'drug_license_number': drugLicenseNumberController.text,
          'average_monthly_sales': double.tryParse(averageMonthlySalesController.text),
          'vendor_category': vendorCategoryController.text,
          'notes': notesController.text,
        }),
      );
print('${ApiEndpoints.baseUrl}/vendor/profile/update');
print(json.encode({
  'user_id': userId.value,
  'name': nameController.text,
  'email': emailController.text,
  'phone': phoneController.text,
  'business_name': businessNameController.text,
  'business_type': businessTypeController.text,
  'contact_person': contactPersonController.text,
  'designation': designationController.text,
  'gst_number': gstNumberController.text,
  'company_registration_number': companyRegistrationNumberController.text,
  'year_of_establishment': int.tryParse(yearOfEstablishmentController.text),
  'drug_license_number': drugLicenseNumberController.text,
  'average_monthly_sales': double.tryParse(averageMonthlySalesController.text),
  'vendor_category': vendorCategoryController.text,
  'notes': notesController.text,
}),);
print(response.body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == true) {
          // Update observable values
          name.value = nameController.text;
          email.value = emailController.text;
          phone.value = phoneController.text;
          businessName.value = businessNameController.text;
          businessType.value = businessTypeController.text;
          contactPerson.value = contactPersonController.text;
          designation.value = designationController.text;
          gstNumber.value = gstNumberController.text;
          companyRegistrationNumber.value = companyRegistrationNumberController.text;
          yearOfEstablishment.value = yearOfEstablishmentController.text;
          drugLicenseNumber.value = drugLicenseNumberController.text;
          averageMonthlySales.value = double.tryParse(averageMonthlySalesController.text) ?? 0;
          vendorCategory.value = vendorCategoryController.text;
          notes.value = notesController.text;

          // Update stored vendor ID if returned
          if (jsonData['vendor_id'] != null) {
            vendorId.value = jsonData['vendor_id'];
          }

          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
          );

          isEditing.value = false;
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isSaving.value = false;
    }
  }

  String getFormattedRevenue(double revenue) {
    if (revenue >= 100000) {
      return '₹${(revenue / 100000).toStringAsFixed(1)}L';
    } else if (revenue >= 1000) {
      return '₹${(revenue / 1000).toStringAsFixed(1)}K';
    }
    return currencyFormat.format(revenue);
  }

  void logout() async {
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Logout',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    businessNameController.dispose();
    businessTypeController.dispose();
    contactPersonController.dispose();
    designationController.dispose();
    gstNumberController.dispose();
    companyRegistrationNumberController.dispose();
    yearOfEstablishmentController.dispose();
    drugLicenseNumberController.dispose();
    averageMonthlySalesController.dispose();
    vendorCategoryController.dispose();
    notesController.dispose();
    super.onClose();
  }
}