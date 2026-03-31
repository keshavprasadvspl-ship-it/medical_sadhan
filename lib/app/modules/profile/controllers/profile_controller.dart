import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/providers/api_provider.dart';
import '../../../data/providers/cart_service.dart';

class ProfileController extends GetxController {
  // Login status
  final isLoggedIn = false.obs;

  // User data from user object
  final userId = 0.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;
  final userPhone = ''.obs;
  final userType = ''.obs;
  final referalCode = ''.obs;
  final isVerified = false.obs;
  final createdAt = ''.obs;

  // Buyer/Business data from buyer object
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

  // Loading state
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Menu items - Full menu for logged in users
  final List<Map<String, dynamic>> fullMenuItems = [
    {
      'icon': Icons.person_outline,
      'title': 'Edit Profile',
      'subtitle': 'Update your business information',
      'route': '/edit-profile',
    },
    {
      'icon': Icons.subscriptions,
      'title': 'Subscription',
      'subtitle': 'Subscription Plans and Subscribe',
      'route': '/subscription',
    },
    {
      'icon': Icons.location_on_outlined,
      'title': 'Delivery Address',
      'subtitle': 'Manage your delivery locations',
      'route': '/address',
    },
    {
      'icon': Icons.notifications_outlined,
      'title': 'Notifications',
      'subtitle': 'Manage notification preferences',
      'route': '/notifications',
    },
    {
      'icon': Icons.help_outline,
      'title': 'Help & Support',
      'subtitle': 'Get help and contact support',
      'route': '/help-support',
    },
    {
      'icon': Icons.privacy_tip_outlined,
      'title': 'Privacy Policy',
      'subtitle': 'Read our privacy policy',
      'route': '/privacy-policy',
    },
  ];

  // Limited menu for non-logged in users
  final List<Map<String, dynamic>> limitedMenuItems = [
    {
      'icon': Icons.help_outline,
      'title': 'Help & Support',
      'subtitle': 'Get help and contact support',
      'route': '/help-support',
    },
    {
      'icon': Icons.privacy_tip_outlined,
      'title': 'Privacy Policy',
      'subtitle': 'Read our privacy policy',
      'route': '/privacy-policy',
    },
  ];

  // Getter for menu items based on login status
  List<Map<String, dynamic>> get menuItems {
    return isLoggedIn.value ? fullMenuItems : limitedMenuItems;
  }

  // Stats items - Updated to show business stats
  final List<Map<String, dynamic>> statsItems = [
    {'title': 'Credit Days', 'value': '0', 'icon': Icons.calendar_today_outlined},
    {'title': 'Credit Limit', 'value': '₹0', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Branches', 'value': '0', 'icon': Icons.business_outlined},
  ];

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // Check login status from SharedPreferences
  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      final userDataString = prefs.getString('user_data');

      if (authToken != null && authToken.isNotEmpty && userDataString != null) {
        isLoggedIn.value = true;

        // Load user data from prefs
        final userData = json.decode(userDataString);
        userId.value = userData['id'] ?? 0;
        userName.value = userData['name']?.toString() ?? '';
        userEmail.value = userData['email']?.toString() ?? '';
        userPhone.value = userData['phone']?.toString() ?? '';

        // Fetch fresh profile data from API
        await fetchProfileFromApi();
      } else {
        isLoggedIn.value = false;
        isLoading.value = false;
      }
    } catch (e) {
      print('Error checking login status: $e');
      isLoggedIn.value = false;
      isLoading.value = false;
    }
  }

  // Fetch profile from API (always fresh data)
  Future<void> fetchProfileFromApi() async {
    if (!isLoggedIn.value) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (userId.value == 0) {
        final userDataString = prefs.getString('user_data');
        if (userDataString != null) {
          final userData = json.decode(userDataString);
          userId.value = userData['id'] ?? 0;
        }
      }

      final apiService = Get.find<ApiService>();
      final response = await apiService.getBuyerProfile(
        userId: userId.value,
        token: authToken,
      );

      if (response['status'] == true && response['data'] != null) {
        final userData = response['data']['user'];
        final buyerData = response['data']['buyer'];

        // Update user data
        if (userData != null) {
          userId.value = userData['id'] ?? userId.value;
          userName.value = userData['name']?.toString() ?? '';
          userEmail.value = userData['email']?.toString() ?? '';
          userPhone.value = userData['phone']?.toString() ?? '';
          userType.value = userData['type']?.toString() ?? 'buyer';
          referalCode.value = userData['referal_code']?.toString() ?? '';
          isVerified.value = userData['is_verified'] ?? false;
          createdAt.value = userData['created_at']?.toString() ?? '';
        }

        // Update buyer/business data
        if (buyerData != null) {
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
        }

        // Update SharedPreferences with fresh data
        await prefs.setString('user_data', json.encode({
          'id': userId.value,
          'name': userName.value,
          'email': userEmail.value,
          'phone': userPhone.value,
          'type': userType.value,
        }));

        // Update stats
        updateStats();
      } else {
        errorMessage.value = response['message'] ?? 'Failed to fetch profile';
      }
    } catch (e) {
      print('Error fetching from API: $e');
      errorMessage.value = 'Network error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Update stats values
  void updateStats() {
    statsItems[0]['value'] = creditDays.value.toString();
    statsItems[1]['value'] = '₹${creditLimit.value.toStringAsFixed(0)}';
    statsItems[2]['value'] = totalBranches.value.toString();
  }

  // Navigation method
  void navigateToMenuItem(String route) {
    // For protected routes, check if user is logged in
    if (!isLoggedIn.value && route != '/help-support' && route != '/privacy-policy') {
      Get.snackbar(
        'Login Required',
        'Please login to access this feature',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Future.delayed(const Duration(milliseconds: 30), () {
      Get.toNamed(route)?.then((value) {
        // Refresh profile when returning from edit profile
        if (route == '/edit-profile' && isLoggedIn.value) {
          fetchProfileFromApi();
        }
      });
    });
  }

  // Navigate to login
  void goToLogin() {
    Get.toNamed('/login');
  }

  // Remove FCM token on logout
  Future<void> removeFCMTokenOnLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (userId.value != 0 && authToken != null) {
        final apiService = Get.find<ApiService>();
        await apiService.removeDeviceToken(
          userId: userId.value,
          authToken: authToken,
        );
      }
    } catch (e) {
      print('Error removing token on logout: $e');
    }
  }

  // Logout function
  Future<void> logout() async {
    final result = await Get.defaultDialog<bool>(
      title: 'Logout',
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111261),
      ),
      middleText: 'Are you sure you want to logout?',
      middleTextStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
      radius: 16,
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      cancelTextColor: const Color(0xFF111261),
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (result == true) {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0B630B),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        await Get.find<CartService>().clearAllCartData();

        // Remove FCM token
        await removeFCMTokenOnLogout();

        // Clear all auth data
        await prefs.remove('auth_token');
        await prefs.remove('user_data');

        // Update login status
        isLoggedIn.value = false;

        // Clear profile data
        clearProfileData();

        Get.back();

        Get.snackbar(
          'Success',
          'Logged out successfully',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        Get.back();
        Get.snackbar(
          'Error',
          'Failed to logout: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // Clear profile data on logout
  void clearProfileData() {
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
    businessName.value = '';
    gstNumber.value = '';
    profileImage.value = '';
    creditDays.value = 0;
    creditLimit.value = 0.0;
    totalBranches.value = 0;
  }

  // Method to refresh profile data (always from API)
  Future<void> refreshProfile() async {
    if (isLoggedIn.value) {
      await fetchProfileFromApi();
    }
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
}