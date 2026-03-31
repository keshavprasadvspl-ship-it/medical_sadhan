import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/providers/api_provider.dart';
import '../../../services/storage_service.dart';

class AuthController extends GetxController {
  late SharedPreferences _prefs;
  final ApiService _apiService = ApiService();


  final companyDivisions = <Map<String, dynamic>>[].obs;
  final selectedDivisions = <Map<String, dynamic>>[].obs;
  final isLoadingDivisions = false.obs;

  // Observable variables
  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var isOtpLoading = false.obs;
  var isResendLoading = false.obs;
  var userType = 'buyer'.obs;
  var onboardingStep = 0.obs;
  var selectedCompanies = <String>[].obs;
  var selectedCategories = <String>[].obs;
  var selectedSubCategories = <Map<String, dynamic>>[].obs;


  var phoneNumber = ''.obs;
  var phoneOtp = ''.obs;
  var phoneLoginLoading = false.obs;
  var phoneOtpSent = false.obs;



  // Forgot Password Flow Variables
  var email = ''.obs;
  var otpCode = ''.obs;
  var resetToken = ''.obs;
  var canResend = true.obs;
  var secondsRemaining = 60.obs;


  // API Data
  var companies = <Map<String, dynamic>>[].obs;
  var categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await initializePrefs();
    checkLoginStatus();
    await loadCompanies();
    await loadCategories();
  }

  Future<void> initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void checkLoginStatus() {
    final token = _prefs.getString('auth_token');
    final userDataString = _prefs.getString('user_data');

    if (token != null && userDataString != null) {
      try {
        isLoggedIn.value = true;
        final userData = userDataString.isNotEmpty
            ? Map<String, dynamic>.from(json.decode(userDataString))
            : {};

        userType.value = userData['type'] ?? 'buyer';

        // Load selections from storage
        final storedCompanies =
            _prefs.getStringList('selected_companies') ?? [];
        final storedCategories =
            _prefs.getStringList('selected_categories') ?? [];
        final storedSubCategories = _prefs.getString('selected_subcategories');

        selectedCompanies.assignAll(storedCompanies);
        selectedCategories.assignAll(storedCategories);

        if (storedSubCategories != null && storedSubCategories.isNotEmpty) {
          final subCatList = List<Map<String, dynamic>>.from(
            json.decode(storedSubCategories),
          );
          selectedSubCategories.assignAll(subCatList);
        }

        // Check if seller/vendor needs onboarding
        if ((userType.value == 'seller' || userType.value == 'vendor') &&
            (userData['onboarding_complete'] != true)) {
          onboardingStep.value = 1;
        }
      } catch (e) {
        print('Error parsing stored user data: $e');
        logout();
      }
    } else {
      isLoggedIn.value = false;
    }
  }

  Future<void> loadCompanyDivisions() async {
    try {
      isLoadingDivisions.value = true;

      // Fetch divisions from API
      final result = await _apiService.getAllDivisions(); // Implement this method

      if (result['success'] == true) {
        final data = result['data'];
        if (data is List) {
          companyDivisions.value = List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data.containsKey('data')) {
          companyDivisions.value = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('Error loading divisions: $e');
      // Load default divisions as fallback

    } finally {
      isLoadingDivisions.value = false;
    }
  }



// Toggle division selection
  void toggleDivisionSelection(Map<String, dynamic> division) {
    final index = selectedDivisions.indexWhere((d) => d['id'] == division['id']);

    if (index == -1) {
      selectedDivisions.add(division);
    } else {
      selectedDivisions.removeAt(index);
    }
  }

// Select a division
  void selectDivision(Map<String, dynamic> division) {
    final index = selectedDivisions.indexWhere((d) => d['id'] == division['id']);
    if (index == -1) {
      selectedDivisions.add(division);
    }
  }

// Deselect a division
  void deselectDivision(String divisionId) {
    selectedDivisions.removeWhere((d) => d['id'] == divisionId);
  }

// Clear all selections
  void clearDivisionSelections() {
    selectedDivisions.clear();
  }



  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      phoneLoginLoading.value = true;

      final response = await _apiService.verifyPhoneOtp(
        phone: phone,
        otp: otp,
      );

      if (response['success'] == true) {

        final token = response['data']?['token'] ?? response['token'];
        final userData = response['data']?['user'] ?? response['user'] ?? {};

        if (token == null) {
          throw Exception("Token not received");
        }

        final actualUserType = userData['type'] ?? 'buyer';

        await _prefs.setString('auth_token', token);

        await _saveUserData({
          ...userData,
          'type': actualUserType,
          'onboarding_complete': true,
        });

        await registerFCMTokenOnLogin();

        userType.value = actualUserType;
        isLoggedIn.value = true;

        Get.snackbar(
          "Success",
          "Logged in successfully",
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
        );

        await syncCartWithServer();

        await Future.delayed(const Duration(milliseconds: 300));

        if (actualUserType == 'buyer') {
          await Get.offAllNamed('/main');
        } else {
          await Get.offAllNamed('/venders-dashboard');
        }

      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Invalid OTP",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString().replaceAll("Exception:", ""),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      phoneLoginLoading.value = false;
    }
  }

  Future<bool> sendPhoneOtp(String phone) async {
    try {
      phoneLoginLoading.value = true;
      phoneNumber.value = phone;

      final response = await _apiService.sendPhoneOtp(phone);

      if (response['success'] == true) {
        phoneOtpSent.value = true;

        Get.snackbar(
          "OTP Sent",
          response['message'] ?? "OTP sent to your phone",
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
        );

        if (response['debug_otp'] != null) {

          phoneOtp.value = "${response['debug_otp']}";
          print("phone response");
          print(response['debug_otp']);
          print("Phone Debug OTP: ${response['debug_otp']}");
        }

        return true;
      } else {
        Get.snackbar(
          "Error",
          response['message'] ?? "Failed to send OTP",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Network error",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      phoneLoginLoading.value = false;
    }
  }
  // Save user data to SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      await _prefs.setString('user_data', json.encode(userData));
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  // Save selections to SharedPreferences
  Future<void> _saveSelections() async {
    try {
      await _prefs.setStringList('selected_companies', selectedCompanies);
      await _prefs.setString(
        'selected_categories',
        json.encode(selectedCategories),
      );
      await _prefs.setString(
        'selected_subcategories',
        json.encode(selectedSubCategories),
      );
    } catch (e) {
      print('Error saving selections: $e');
    }
  }

  // Get cart items from local storage
  Future<List<Map<String, dynamic>>> getLocalCartItems() async {
    try {
      final cartString = _prefs.getString('cart_items');
      if (cartString != null && cartString.isNotEmpty) {
        return List<Map<String, dynamic>>.from(json.decode(cartString));
      }
    } catch (e) {
      print('Error getting local cart items: $e');
    }
    return [];
  }

  // Clear local cart items
  Future<void> clearLocalCart() async {
    try {
      await _prefs.remove('cart_items');
      print('Local cart cleared');
    } catch (e) {
      print('Error clearing local cart: $e');
    }
  }

  // Sync local cart with server
  Future<void> syncCartWithServer() async {
    try {
      // Get local cart items
      final localCartItems = await getLocalCartItems();

      if (localCartItems.isEmpty) {
        print('No local cart items to sync');
        return;
      }

      print('Local cart items to sync: $localCartItems');

      // Get auth token
      final token = getAuthToken();
      if (token == null) {
        print('No auth token found, skipping cart sync');
        return;
      }

      // Show syncing message
      Get.snackbar(
        'Syncing Cart',
        'Syncing your cart items with server...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Call API to sync cart
      final response = await _apiService.syncCart(
        cartItems: localCartItems,
        token: token,
      );

      print('Cart sync response: $response');

      if (response['success'] == true || response['status'] == true) {
        // Clear local cart after successful sync
        await clearLocalCart();

        print('Cart synced successfully with server');

        // Optionally show success message
        Get.snackbar(
          'Cart Synced',
          'Your cart items have been saved to your account',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('Failed to sync cart: ${response['message']}');
      }
    } catch (e) {
      print('Error syncing cart with server: $e');
    }
  }

  // Load companies from API
  Future<void> loadCompanies() async {
    try {
      isLoading.value = true;
      final apiCompanies = await _apiService.getCompanies();
      companies.value = apiCompanies;
    } catch (e) {
      print('Failed to load companies: $e');
      Get.snackbar(
        'Error',
        'Failed to load companies. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // Load categories from API
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      final apiCategories = await _apiService.getCategories();
      categories.value = apiCategories;
    } catch (e) {
      print('Failed to load categories: $e');
      Get.snackbar(
        'Error',
        'Failed to load categories. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required String userType, // This is the selected type from login screen
  }) async {
    try {
      isLoading.value = true;

      print("Starting login process for user type: $userType");

      // Call API for login
      final response = await _apiService.loginUser(
        email: email,
        password: password,
      );

      print("Full response received:");
      print(response);

      if (response['success'] == true) {
        print("Login successful, processing response...");

        // Extract token
        final token = response['data']?['token'] ?? response['token'];

        if (token == null) {
          throw Exception('No token received from server');
        }

        // Extract user data from response
        final userData = response['data']?['user'] ?? response['user'] ?? {};

        // Get the actual user type from API response (this is the source of truth)
        final actualUserType = userData['type'] ?? userType;

        // Check if onboarding is complete (you need to track this in your backend)
        // For now, we'll assume it's false for vendors and true for buyers
        // You should get this from your API response
        final onboardingComplete = actualUserType == 'buyer' ? true : true;

        print("Extracted user data: $userData");
        print("User type from response: $actualUserType");
        print("Onboarding complete: $onboardingComplete");

        // Store token and user data in SharedPreferences
        await _prefs.setString('auth_token', token);
        print("Token saved to SharedPreferences");

        await _saveUserData({
          ...userData,
          'type': actualUserType,
          'onboarding_complete': onboardingComplete,
        });
        await registerFCMTokenOnLogin();
        print("User data saved to SharedPreferences");

        this.userType.value = actualUserType;
        isLoggedIn.value = true;
        print("UserType set to: $actualUserType, isLoggedIn set to: true");

        // Show success message
        Get.snackbar(
          'Success',
          'Logged in successfully',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // SYNC CART WITH SERVER
        await syncCartWithServer();

        // Add a small delay to ensure everything is settled
        await Future.delayed(const Duration(milliseconds: 500));

        // Redirect based on user type AND onboarding status
        if (actualUserType == 'buyer') {
          // Buyers go directly to main screen
          print("Redirecting buyer to main screen...");
          await Get.offAllNamed('/main');
        } else {
          // For vendors/sellers, check if onboarding is complete
          if (onboardingComplete) {
            // If onboarding is complete, go directly to vendor dashboard
            print("Vendor onboarding complete - redirecting to dashboard...");
            await Get.offAllNamed('/venders-dashboard');
          } else {
            // If onboarding is not complete, go to company selection
            print("Vendor needs onboarding - redirecting to company selection...");
            onboardingStep.value = 1;

            // Load companies and categories for vendor onboarding
            try {
              await loadCompanies();
              await loadCategories();
              print("Companies and categories loaded for vendor onboarding");
            } catch (e) {
              print("Error loading vendor data: $e");
            }

            await Get.offAllNamed('/seller/company-selection');
          }
        }

        print("Login process completed successfully");
      } else {
        final errorMsg = response['message'] ?? 'Login failed';
        print("Login failed with message: $errorMsg");
        Get.snackbar(
          'Login Failed',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error during login: $e");
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print("isLoading set to false");
    }
  }

  // Future<void> register({
  //   required String name,
  //   required String email,
  //   required String phone,
  //   required String password,
  //   required String confirmPassword,
  //   required String userType,
  //   String? companyName,
  //   String? gstNumber,
  //   String? businessAddress, required String dlNumber,
  // }) async {
  //   try {
  //     isLoading.value = true;
  //
  //     if (password != confirmPassword) {
  //       throw Exception('Passwords do not match');
  //     }
  //
  //     if (userType == 'vendor' || userType == 'seller') {
  //       if (companyName == null || companyName.isEmpty) {
  //         throw Exception('Company name is required for vendors');
  //       }
  //       if (gstNumber == null || gstNumber.isEmpty) {
  //         throw Exception('GST number is required for vendors');
  //       }
  //     }
  //
  //     // Prepare additional data for vendor
  //     Map<String, dynamic> additionalData = {};
  //     if (userType == 'vendor' || userType == 'seller') {
  //       additionalData = {
  //         'company_name': companyName,
  //         'gst_number': gstNumber,
  //         'business_address': businessAddress,
  //       };
  //     }
  //
  //     // Call API for registration
  //     final response = await _apiService.registerUser(
  //       name: name,
  //       email: email,
  //       phone: phone,
  //       password: password,
  //       passwordConfirmation: confirmPassword,
  //       type: userType,
  //     );
  //
  //     print("Registration response:");
  //     print(response);
  //
  //     if (response['success'] == true) {
  //       final token = response['data']['token'] ?? response['token'];
  //       final userData = response['data']['user'] ?? response['user'] ?? {};
  //
  //       // For vendors, onboarding is NOT complete after registration
  //       // For buyers, onboarding is complete (they don't need onboarding)
  //       final onboardingComplete = (userType == 'buyer') ? true : true;
  //
  //       // Store token and user data in SharedPreferences
  //       await _prefs.setString('auth_token', token);
  //       await _saveUserData({
  //         ...userData,
  //         ...additionalData,
  //         'type': userType,
  //         'phone': phone,
  //         'onboarding_complete': onboardingComplete,
  //       });
  //
  //       this.userType.value = userType;
  //       isLoggedIn.value = true;
  //
  //       // Show success message
  //       Get.snackbar(
  //         'Success',
  //         'Account created successfully',
  //         backgroundColor: const Color(0xFF0B630B),
  //         colorText: Colors.white,
  //         duration: const Duration(seconds: 2),
  //       );
  //
  //       // SYNC CART WITH SERVER
  //       await syncCartWithServer();
  //
  //       // Navigate based on user type
  //       if (userType == 'buyer') {
  //         // Buyers go directly to main screen
  //         print("Redirecting buyer to main screen...");
  //         await Get.offAllNamed('/main');
  //       } else {
  //         // Vendors always go through onboarding process
  //         print("Redirecting vendor to company selection for onboarding...");
  //
  //         // Load companies and categories for vendor onboarding
  //         try {
  //           await loadCompanies();
  //           await loadCategories();
  //           print("Companies and categories loaded for vendor onboarding");
  //         } catch (e) {
  //           print("Error loading vendor data after registration: $e");
  //           // Continue with onboarding even if loading fails
  //           // You might want to show a snackbar here
  //           Get.snackbar(
  //             'Warning',
  //             'Failed to load some data. Please try again later.',
  //             backgroundColor: Colors.orange,
  //             colorText: Colors.white,
  //           );
  //         }
  //
  //         // Set onboarding step to 1 (company selection)
  //         onboardingStep.value = 1;
  //
  //         // Navigate to company selection screen
  //         await Get.offAllNamed('/vendors-company-selection');
  //       }
  //     } else {
  //       throw Exception(response['message'] ?? 'Registration failed');
  //     }
  //   } catch (e) {
  //     print('Registration error: $e');
  //     Get.snackbar(
  //       'Registration Failed',
  //       e.toString().replaceAll('Exception:', '').trim(),
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }



  // In your AuthController, update the register method
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String userType,
    String? companyName,
    String? gstNumber,
    String? businessAddress,
    required String dlNumber,
  }) async {
    try {
      isLoading.value = true;

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      if (userType == 'vendor' || userType == 'seller') {
        if (companyName == null || companyName.isEmpty) {
          throw Exception('Company name is required for vendors');
        }
        if (gstNumber == null || gstNumber.isEmpty) {
          throw Exception('GST number is required for vendors');
        }
      }

      // Prepare additional data for vendor
      Map<String, dynamic> additionalData = {};
      if (userType == 'vendor' || userType == 'seller') {
        additionalData = {
          'company_name': companyName,
          'gst_number': gstNumber,
          'business_address': businessAddress,
        };
      }

      // Call API for registration
      final response = await _apiService.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: confirmPassword,
        type: userType,
      );

      print("Registration response:");
      print(response);

      if (response['success'] == true) {
        final token = response['data']['token'] ?? response['token'];
        final userData = response['data']['user'] ?? response['user'] ?? {};

        // For vendors, onboarding is NOT complete after registration
        // For buyers, onboarding is complete (they don't need onboarding)
        final onboardingComplete = (userType == 'buyer') ? true : false;

        // Store token and user data in SharedPreferences
        await _prefs.setString('auth_token', token);
        await _saveUserData({
          ...userData,
          ...additionalData,
          'type': userType,
          'phone': phone,
          'onboarding_complete': onboardingComplete,
        });

        this.userType.value = userType;
        isLoggedIn.value = true;

        // Show success message
        Get.snackbar(
          'Success',
          'Account created successfully',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // SYNC CART WITH SERVER
        await syncCartWithServer();

        // Navigate based on user type
        if (userType == 'buyer') {
          // Buyers go directly to main screen
          print("Redirecting buyer to main screen...");
          await Get.offAllNamed('/main');
        } else {
          // ✅ UPDATED: Vendors go to CATEGORY SELECTION first
          print("Redirecting vendor to category selection for onboarding...");

          // Load categories for vendor onboarding
          try {
            await loadCategories();
            print("Categories loaded for vendor onboarding");
          } catch (e) {
            print("Error loading categories after registration: $e");
            Get.snackbar(
              'Warning',
              'Failed to load categories. Please try again later.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }

          // Set onboarding step to 1 (category selection)
          onboardingStep.value = 1;

          // Navigate to category selection screen (FIRST STEP)
          await Get.offAllNamed('/vendors-category-selection');
        }
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      Get.snackbar(
        'Registration Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


  void toggleCompanySelection(String companyId) {
    if (selectedCompanies.contains(companyId)) {
      selectedCompanies.remove(companyId);
    } else {
      selectedCompanies.add(companyId);
    }
    _saveSelections();
  }

  void toggleCategorySelection(String categoryId) {
    final categoryIndex = categories.indexWhere(
          (cat) => cat['id'] == categoryId,
    );
    if (categoryIndex == -1) return;

    final category = categories[categoryIndex];

    if (selectedCategories.contains(categoryId)) {
      // Remove category and its subcategories
      selectedCategories.remove(categoryId);
      selectedSubCategories.removeWhere(
            (subCat) => subCat['categoryId'] == categoryId,
      );
    } else {
      // Add category and all its subcategories
      selectedCategories.add(categoryId);

      final subCategories = (category['subCategories'] as List?) ?? [];
      for (var subCat in subCategories) {
        selectedSubCategories.add({
          'id': subCat['id'].toString(),
          'name': subCat['name'] ?? '',
          'categoryId': categoryId,
          'categoryName': category['name'] ?? '',
          'selected': true,
        });
      }
    }
    _saveSelections();
  }

  void toggleSubCategorySelection(Map<String, dynamic> subCategory) {
    final exists = selectedSubCategories.any((sc) => sc['id'] == subCategory['id']);

    if (exists) {
      // Remove subcategory
      selectedSubCategories.removeWhere((sc) => sc['id'] == subCategory['id']);
    } else {
      // Add subcategory
      selectedSubCategories.add({
        'id': subCategory['id'].toString(),
        'name': subCategory['name']?.toString() ?? 'Unknown',
        'categoryId': subCategory['categoryId'].toString(),
        'categoryName': subCategory['categoryName']?.toString() ?? 'Unknown',
      });
    }
    _saveSelections();
  }

  void proceedToCategories() {
    if (selectedCompanies.isEmpty) {
      Get.snackbar(
        'Selection Required',
        'Please select at least one company',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    onboardingStep.value = 2;
    Get.toNamed('/vendors-category-selection');
  }

  Future<void> completeOnboarding() async {

    try {
      print("selectedSubCategories");
      print(selectedSubCategories);
      if (selectedCategories.isEmpty) {
        Get.snackbar(
          'Selection Required',
          'Please select at least one category or subcategory',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      final userData = getUserData();
      final vendorId = userData?['id']?.toString() ?? userData?['vendor_id']?.toString();

      if (vendorId == null) {
        throw Exception('Vendor ID not found. Please login again.');
      }

      final token = getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final response = await _apiService.assignVendorProducts(
        vendorId: vendorId,
        companyIds: selectedCompanies.toList(),
        categoryIds: selectedCategories.toList(),
        subCategoryIds: selectedSubCategories
            .map((sc) => sc['id'].toString())
            .toList(),
        token: token,
      );

      if (response['status'] == true) {
        // Update user data with onboarding complete
        final userDataString = _prefs.getString('user_data');
        if (userDataString != null && userDataString.isNotEmpty) {
          final updatedUserData = Map<String, dynamic>.from(
            json.decode(userDataString),
          );
          updatedUserData['onboarding_complete'] = true;
          await _saveUserData(updatedUserData);
          await registerFCMTokenOnLogin();
        }

        Get.snackbar(
          'Onboarding Complete!',
          '${response['total_processed'] ?? 0} products assigned successfully',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Clear selections
        selectedCompanies.clear();
        selectedCategories.clear();
        selectedSubCategories.clear();
        onboardingStep.value = 0;

        // Clear stored selections
        await _prefs.remove('selected_companies');
        await _prefs.remove('selected_categories');
        await _prefs.remove('selected_subcategories');

        await Get.offAllNamed('/venders-dashboard');
      } else {
        throw Exception(response['message'] ?? 'Failed to assign products');
      }
    } catch (e) {
      print('Error in completeOnboarding: $e');
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final token = _prefs.getString('auth_token');
      if (token != null) {
        await _apiService.logoutUser(token);
      }
      await removeFCMTokenOnLogout();
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      // Clear all SharedPreferences data
      await _prefs.clear();

      // Reset state
      isLoggedIn.value = false;
      selectedCompanies.clear();
      selectedCategories.clear();
      selectedSubCategories.clear();
      onboardingStep.value = 0;
      companies.clear();
      categories.clear();


      // Navigate to login
      await Get.offAllNamed('/login');

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        backgroundColor: const Color(0xFF111261),
        colorText: Colors.white,
      );
    }
  }


  // In your AuthController class
  Future<void> removeFCMTokenOnLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      final authToken = prefs.getString('auth_token');

      if (userDataString != null && authToken != null) {
        final userData = json.decode(userDataString);
        final userId = userData['id'];

        if (userId != null) {
          final apiService = Get.find<ApiService>();
          final response = await apiService.removeDeviceToken(
            userId: userId,
            authToken: authToken,
          );

          if (response['success'] == true) {
            print('✅ FCM token removed on logout');
          } else {
            print('❌ Failed to remove FCM token: ${response['message']}');
          }
        }
      }
    } catch (e) {
      print('❌ Error removing token on logout: $e');
    }
  }



  // 1. Send OTP to email
  Future<bool> sendOtp(String email) async {
    try {
      isLoading.value = true;
      this.email.value = email;

      final response = await _apiService.sendOtp(email);

      if (response['success'] == true) {
        Get.snackbar(
          'OTP Sent',
          response['message'] ?? 'OTP sent to your email',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // If in debug mode and OTP is returned, you can auto-fill
        if (response['debug_otp'] != null) {
          otpCode.value = response['debug_otp'];
          print('Debug OTP: ${response['debug_otp']}');
        }

        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to send OTP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Verify OTP
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      isOtpLoading.value = true;

      final response = await _apiService.verifyOtp(email, otp);

      if (response['success'] == true) {
        resetToken.value = response['reset_token'] ?? '';

        Get.snackbar(
          'Success',
          response['message'] ?? 'OTP verified successfully',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Invalid OTP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isOtpLoading.value = false;
    }
  }

  // 3. Resend OTP
  Future<void> resendOtp(String email) async {
    try {
      isResendLoading.value = true;
      canResend.value = false;

      final response = await _apiService.resendOtp(email);

      if (response['success'] == true) {
        Get.snackbar(
          'OTP Resent',
          response['message'] ?? 'New OTP sent to your email',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Start resend timer
        startResendTimer();

        // If in debug mode and OTP is returned
        if (response['debug_otp'] != null) {
          otpCode.value = response['debug_otp'];
          print('New Debug OTP: ${response['debug_otp']}');
        }
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to resend OTP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        canResend.value = true;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      canResend.value = true;
    } finally {
      isResendLoading.value = false;
    }
  }

  // 4. Reset Password
  Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;

      final response = await _apiService.resetPassword(
        email: email,
        resetToken: resetToken,
        password: password,
        passwordConfirmation: confirmPassword,
      );

      if (response['success'] == true) {
        // Clear forgot password flow data
        clearForgotPasswordData();

        Get.snackbar(
          'Success',
          response['message'] ?? 'Password reset successfully',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to reset password',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 5. Change Password (for authenticated users)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmPassword,
        token: token,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          response['message'] ?? 'Password changed successfully',
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to change password',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }



  // In your AuthController class
// In your AuthController class
  Future<void> registerFCMTokenOnLogin() async {
    final storageService = Get.find<StorageService>();

    // ✅ FIX: Add await here
    final fcmToken = await storageService.getString('fcm_token');
print("storede fcm token");
print(fcmToken);
    // Now check if it's not null and not empty
    if (fcmToken != null && fcmToken.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      final authToken = prefs.getString('auth_token');

      if (userDataString != null && authToken != null) {
        try {
          final userData = json.decode(userDataString);
          final userId = userData['id'];

          if (userId != null) {
            final apiService = Get.find<ApiService>();
            await apiService.registerDeviceToken(
              userId: userId,
              deviceToken: fcmToken, // ✅ Now this is a String, not a Future
              deviceType: GetPlatform.isIOS ? 'ios' : 'android',
              authToken: authToken,
            );
            print('✅ FCM token registered after login');
          }
        } catch (e) {
          print('❌ Error registering token after login: $e');
        }
      }
    }
  }


  void startResendTimer() {
    secondsRemaining.value = 60;
    canResend.value = false;

    Future.delayed(const Duration(seconds: 1), () {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
        startResendTimer();
      } else {
        canResend.value = true;
      }
    });
  }

  void clearForgotPasswordData() {
    email.value = '';
    otpCode.value = '';
    resetToken.value = '';
    canResend.value = true;
    secondsRemaining.value = 60;
  }

  // Get stored user data
  Map<String, dynamic>? getUserData() {
    final userDataString = _prefs.getString('user_data');
    if (userDataString != null && userDataString.isNotEmpty) {
      try {
        return Map<String, dynamic>.from(json.decode(userDataString));
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  // Get auth token
  String? getAuthToken() {
    return _prefs.getString('auth_token');
  }

  // Check if company is selected
  bool isCompanySelected(String companyId) {
    return selectedCompanies.contains(companyId);
  }

  // Check if category is selected
  bool isCategorySelected(String categoryId) {
    return selectedCategories.contains(categoryId);
  }

  // Check if subcategory is selected
  bool isSubCategorySelected(String subCategoryId) {
    return selectedSubCategories.any((sc) => sc['id'] == subCategoryId);
  }

  // Get selected subcategories for a category
  List<Map<String, dynamic>> getSelectedSubCategoriesForCategory(
      String categoryId,
      ) {
    return selectedSubCategories
        .where((sc) => sc['categoryId'] == categoryId)
        .toList();
  }

  // For selecting all subcategories of a category (used by "Select All" button)
  void selectSubCategory(Map<String, dynamic> subCategory) {
    final exists = selectedSubCategories.any((sc) => sc['id'] == subCategory['id']);

    if (!exists) {
      selectedSubCategories.add({
        'id': subCategory['id'].toString(),
        'name': subCategory['name']?.toString() ?? 'Unknown',
        'categoryId': subCategory['categoryId'].toString(),
        'categoryName': subCategory['categoryName']?.toString() ?? 'Unknown',
      });
    }
    _saveSelections();
  }

// For deselecting a specific subcategory
  void deselectSubCategory(String subCategoryId) {
    selectedSubCategories.removeWhere((sc) => sc['id'] == subCategoryId);
    _saveSelections();
  }
}