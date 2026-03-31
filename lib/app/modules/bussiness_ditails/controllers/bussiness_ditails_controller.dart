import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/api_provider.dart';

class BusinessDetailsController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // User data from user object
  final userId = 0.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final userType = ''.obs;
  final referalCode = ''.obs;
  final isUserVerified = false.obs;
  final createdAt = ''.obs;
  final updatedAt = ''.obs;

  // Buyer/Business data from buyer object
  final buyerId = 0.obs;
  final businessName = ''.obs;
  final businessType = ''.obs;
  final contactPerson = ''.obs;
  final designation = ''.obs;
  final gstNumber = ''.obs;
  final licenseNumber = ''.obs;
  final establishmentYear = 0.obs;
  final totalBranches = 0.obs;
  final businessRegistrationNumber = ''.obs;
  final averageMonthlyPurchase = 0.0.obs;
  final creditLimit = 0.0.obs;
  final creditUsed = 0.0.obs;
  final creditAvailable = 0.obs;
  final creditDays = 0.obs;
  final preferredPaymentMethod = ''.obs;
  final buyerCategory = ''.obs;
  final isBuyerVerified = false.obs;
  final verifiedBy = ''.obs;
  final verificationDate = ''.obs;
  final notes = ''.obs;
  final profileImage = ''.obs;
  final preferences = Rx<Map<String, dynamic>>({});
  final buyerCreatedAt = ''.obs;
  final buyerUpdatedAt = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBusinessDetails();
  }

  Future<void> fetchBusinessDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // First load user ID from SharedPreferences
      await loadUserIdFromPrefs();

      // Then fetch from API to get latest data
      await fetchFromApi();

    } catch (e) {
      errorMessage.value = 'Failed to load business details';
      print('Error fetching business details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user data
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        userId.value = userData['id'] ?? 0;
        userName.value = userData['name'] ?? '';
        userEmail.value = userData['email'] ?? '';
        userPhone.value = userData['phone'] ?? '';
      }
    } catch (e) {
      print('Error loading user ID from prefs: $e');
    }
  }

  Future<void> fetchFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (userId.value == 0) {
        errorMessage.value = 'User ID not found';
        return;
      }

      final apiService = Get.find<ApiService>();

      // Call API endpoint to get business details
      final response = await apiService.getBuyerProfile(
        userId: userId.value,
        token: authToken,
      );

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];
        final userData = data['user'];
        final buyerData = data['buyer'];

        // Update user data
        if (userData != null) {
          userId.value = userData['id'] ?? userId.value;
          userName.value = userData['name']?.toString() ?? userName.value;
          userEmail.value = userData['email']?.toString() ?? userEmail.value;
          userPhone.value = userData['phone']?.toString() ?? userPhone.value;
          userType.value = userData['type']?.toString() ?? '';
          referalCode.value = userData['referal_code']?.toString() ?? '';
          isUserVerified.value = userData['is_verified'] ?? false;
          createdAt.value = userData['created_at']?.toString() ?? '';
          updatedAt.value = userData['updated_at']?.toString() ?? '';
        }

        // Update buyer/business data
        if (buyerData != null) {
          buyerId.value = buyerData['id'] ?? 0;
          businessName.value = buyerData['business_name']?.toString() ?? '';
          businessType.value = buyerData['business_type']?.toString() ?? '';
          contactPerson.value = buyerData['contact_person']?.toString() ?? '';
          designation.value = buyerData['designation']?.toString() ?? '';
          gstNumber.value = buyerData['gst_number']?.toString() ?? '';
          licenseNumber.value = buyerData['license_number']?.toString() ?? '';
          establishmentYear.value = buyerData['establishment_year'] ?? 0;
          totalBranches.value = buyerData['total_branches'] ?? 0;
          businessRegistrationNumber.value = buyerData['business_registration_number']?.toString() ?? '';

          // Parse numeric values
          averageMonthlyPurchase.value = double.tryParse(buyerData['average_monthly_purchase']?.toString() ?? '0') ?? 0.0;
          creditLimit.value = double.tryParse(buyerData['credit_limit']?.toString() ?? '0') ?? 0.0;
          creditUsed.value = double.tryParse(buyerData['credit_used']?.toString() ?? '0') ?? 0.0;
          creditAvailable.value = buyerData['credit_available'] ?? 0;
          creditDays.value = buyerData['credit_days'] ?? 0;

          preferredPaymentMethod.value = buyerData['preferred_payment_method']?.toString() ?? '';
          buyerCategory.value = buyerData['buyer_category']?.toString() ?? '';
          isBuyerVerified.value = buyerData['is_verified'] ?? false;
          verifiedBy.value = buyerData['verified_by']?.toString() ?? '';
          verificationDate.value = buyerData['verification_date']?.toString() ?? '';
          notes.value = buyerData['notes']?.toString() ?? '';
          profileImage.value = buyerData['profile_image']?.toString() ?? '';

          if (buyerData['preferences'] != null) {
            preferences.value = Map<String, dynamic>.from(buyerData['preferences']);
          }

          buyerCreatedAt.value = buyerData['created_at']?.toString() ?? '';
          buyerUpdatedAt.value = buyerData['updated_at']?.toString() ?? '';
        }

        // Update SharedPreferences with latest data
        await prefs.setString('user_data', json.encode({
          'id': userId.value,
          'name': userName.value,
          'email': userEmail.value,
          'phone': userPhone.value,
        }));

        // Save full response for future use
        await prefs.setString('business_profile', json.encode(response));

      } else {
        errorMessage.value = response['message'] ?? 'Failed to fetch data';
      }
    } catch (e) {
      print('Error fetching from API: $e');
      errorMessage.value = 'Network error. Please try again.';
    }
  }

  void navigateToEditProfile() {
    Get.toNamed('/edit-profile')?.then((value) {
      // Refresh data when returning from edit page
      fetchBusinessDetails();
    });
  }

  String getInitials() {
    if (businessName.value.isNotEmpty) {
      return businessName.value
          .split(' ')
          .map((word) => word.isNotEmpty ? word[0] : '')
          .take(2)
          .join()
          .toUpperCase();
    } else if (userName.value.isNotEmpty) {
      return userName.value
          .split(' ')
          .map((word) => word.isNotEmpty ? word[0] : '')
          .take(2)
          .join()
          .toUpperCase();
    }
    return 'B';
  }

  String getVerificationStatus() {
    if (isBuyerVerified.value) {
      return 'Verified Business';
    } else {
      return 'Pending Verification';
    }
  }

  Color getVerificationColor() {
    if (isBuyerVerified.value) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  String getFormattedCreditLimit() {
    return '₹ ${creditLimit.value.toStringAsFixed(2)}';
  }

  String getFormattedAveragePurchase() {
    return '₹ ${averageMonthlyPurchase.value.toStringAsFixed(2)}';
  }
}