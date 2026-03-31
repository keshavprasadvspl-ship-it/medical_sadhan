// lib/app/middlewares/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/auth/controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Get AuthController - make sure it's initialized in main.dart
    final authController = Get.find<AuthController>();

    // Protected routes
    final protectedRoutes = [
      '/orders',
      '/profile',
      '/edit-profile',
      '/address',
      '/venders',
      '/venders-orders',
      '/venders-dashboard',
      '/venders-order-details',
    ];

    // Check if route is protected
    bool isProtected = false;
    if (route != null) {
      for (var protectedRoute in protectedRoutes) {
        if (route.startsWith(protectedRoute)) {
          isProtected = true;
          break;
        }
      }
    }

    // Redirect logic
    if (isProtected && !authController.isLoggedIn.value) {
      return const RouteSettings(name: '/login');
    }

    if ((route == '/login' || route == '/register') &&
        authController.isLoggedIn.value) {
      return const RouteSettings(name: '/home');
    }

    return null;
  }
}