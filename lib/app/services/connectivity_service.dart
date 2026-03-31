// lib/app/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Make this method public
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      print('Connectivity init error: $e');
      isConnected.value = false;
    }
  }

  // Make this method public if needed elsewhere
  Future<void> checkConnectivity() async {
    await _initConnectivity();
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final previousStatus = isConnected.value;

    // Check if any connection type is available
    final hasConnection = results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);

    isConnected.value = hasConnection;

    // If connection was restored
    if (!previousStatus && hasConnection) {
      Get.snackbar(
        'Back Online',
        'Internet connection restored',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Refresh current page
      final currentRoute = Get.currentRoute;
      if (currentRoute.isNotEmpty) {
        Get.offAllNamed(currentRoute);
      }
    }
    // If connection was lost
    else if (previousStatus && !hasConnection) {
      Get.snackbar(
        'No Internet Connection',
        'You are currently offline',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}