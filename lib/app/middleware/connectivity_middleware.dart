// lib/app/middleware/connectivity_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';

class ConnectivityMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final connectivityService = Get.find<ConnectivityService>();

    // If no internet and trying to access protected route
    if (!connectivityService.isConnected.value &&
        _requiresInternet(route)) {
      return const RouteSettings(name: '/offline');
    }
    return null;
  }

  bool _requiresInternet(String? route) {
    // List routes that require internet connection
    final protectedRoutes = [
      '/main',
      '/vendors-dashboard',
      '/orders',
      '/cart',
      '/profile',
      // Add more protected routes
    ];

    return protectedRoutes.contains(route);
  }
}