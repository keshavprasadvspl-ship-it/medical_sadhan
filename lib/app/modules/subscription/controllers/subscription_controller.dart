import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  // Observable variables
  final selectedPlan = 'monthly'.obs;
  final selectedPaymentMethod = 'card'.obs;
  final agreeToTerms = false.obs;
  final isLoading = false.obs;

  // Promo code variables
  final promoController = TextEditingController();
  final promoCode = ''.obs;
  final isPromoApplied = false.obs;
  final promoError = ''.obs;
  final discountAmount = 0.0.obs;
  final discountPercentage = 0.obs;

  // Sample subscription plans with Indian pricing
  final List<Map<String, dynamic>> plans = [
    {
      'id': 'monthly',
      'name': 'Monthly',
      'price': 999,
      'priceString': '₹999',
      'period': 'per month',
      'features': [
        'Access to all medical supplies',
        'Basic analytics dashboard',
        'Email support',
        'Up to 50 orders/month',
        'GST invoice included',
      ],
      'popular': false,
      'savings': null,
    }
  ];

  // Sample valid promo codes (in real app, this would come from backend)
  final Map<String, Map<String, dynamic>> _validPromoCodes = {
    'WELCOME20': {
      'type': 'percentage',
      'value': 20,
      'description': '20% off',
      'minOrder': 0,
    },
    'SAVE500': {
      'type': 'fixed',
      'value': 500,
      'description': '₹500 off',
      'minOrder': 2500,
    },
    'FIRST100': {
      'type': 'fixed',
      'value': 100,
      'description': '₹100 off',
      'minOrder': 0,
    },
    'PRO10': {
      'type': 'percentage',
      'value': 10,
      'description': '10% off',
      'minOrder': 0,
    },
  };

  // Get selected plan details
  Map<String, dynamic> get selectedPlanDetails {
    return plans.firstWhere((plan) => plan['id'] == selectedPlan.value);
  }

  // Get original price
  double get originalPrice {
    return selectedPlanDetails['price'].toDouble();
  }

  // Get discounted price
  double get discountedPrice {
    if (!isPromoApplied.value) return originalPrice;

    final planPrice = originalPrice;
    if (discountPercentage.value > 0) {
      return planPrice * (1 - discountPercentage.value / 100);
    } else if (discountAmount.value > 0) {
      return (planPrice - discountAmount.value).clamp(0, planPrice);
    }
    return planPrice;
  }

  // Get total savings
  double get totalSavings {
    return originalPrice - discountedPrice;
  }

  // Get formatted original price
  String get formattedOriginalPrice {
    return '₹${originalPrice.toStringAsFixed(0)}';
  }

  // Get formatted discounted price
  String get formattedDiscountedPrice {
    return '₹${discountedPrice.toStringAsFixed(0)}';
  }

  // Get formatted price with GST
  String get priceWithGST {
    if (isPromoApplied.value) {
      return '$formattedDiscountedPrice (incl. 18% GST)';
    }
    return '${selectedPlanDetails['priceString']} (incl. 18% GST)';
  }

  // Apply promo code
  Future<void> applyPromoCode() async {
    final code = promoController.text.trim().toUpperCase();

    if (code.isEmpty) {
      promoError.value = 'Please enter a promo code';
      return;
    }

    isLoading.value = true;
    promoError.value = '';

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (_validPromoCodes.containsKey(code)) {
      final promoData = _validPromoCodes[code]!;

      // Check minimum order condition
      if (originalPrice < promoData['minOrder']) {
        promoError.value = 'Minimum order of ₹${promoData['minOrder']} required';
        isLoading.value = false;
        return;
      }

      // Apply discount based on type
      if (promoData['type'] == 'percentage') {
        discountPercentage.value = promoData['value'];
        discountAmount.value = 0;
      } else {
        discountAmount.value = promoData['value'].toDouble();
        discountPercentage.value = 0;
      }

      promoCode.value = code;
      isPromoApplied.value = true;

      Get.snackbar(
        'Success',
        'Promo code applied! You saved ₹${totalSavings.toStringAsFixed(0)}',
        backgroundColor: const Color(0xFF0B630B),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } else {
      promoError.value = 'Invalid promo code';
      isPromoApplied.value = false;
      discountAmount.value = 0;
      discountPercentage.value = 0;
    }

    isLoading.value = false;
  }

  // Remove promo code
  void removePromoCode() {
    promoController.clear();
    promoCode.value = '';
    isPromoApplied.value = false;
    promoError.value = '';
    discountAmount.value = 0;
    discountPercentage.value = 0;

    Get.snackbar(
      'Removed',
      'Promo code removed',
      backgroundColor: Colors.grey,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void selectPlan(String planId) {
    selectedPlan.value = planId;
    // Reset promo when plan changes
    if (isPromoApplied.value) {
      removePromoCode();
    }
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void toggleTerms(bool? value) {
    agreeToTerms.value = value ?? false;
  }

  // Subscribe method
  Future<void> subscribe() async {
    if (!agreeToTerms.value) {
      Get.snackbar(
        'Error',
        'Please agree to Terms & Conditions',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    String message = 'Subscribed to ${selectedPlanDetails['name']} plan';
    if (isPromoApplied.value) {
      message += ' with promo code ${promoCode.value}';
    }

    Get.snackbar(
      'Success',
      message,
      backgroundColor: const Color(0xFF0B630B),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    promoController.dispose();
    super.onClose();
  }
}