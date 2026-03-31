// lib/app/services/notification_service.dart

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/providers/api_provider.dart';
import 'storage_service.dart';

class NotificationService extends GetxService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final RxString fcmToken = ''.obs;
  late final RxInt unreadCount = 0.obs;

  Future<void> init() async {
    await _requestPermissions();
    await _getToken();
    _setupListeners();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('❌ Notification permissions not granted');
    }
  }

  Future<void> _getToken() async {
    String? token = await _messaging.getToken();
    if (token != null) {
      fcmToken.value = token;
      final storageService = Get.find<StorageService>();
      await storageService.setString('fcm_token', token);
      print('📱 FCM Token: $token');
    }
  }

  void _setupListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background message opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    // Token refresh
    _messaging.onTokenRefresh.listen(_handleTokenRefresh);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message: ${message.messageId}');

    // Show snackbar based on notification type
    _showInAppNotification(message);
  }

  void _handleMessageOpened(RemoteMessage message) {
    print('👆 Message opened from background');
    _navigateFromNotification(message.data);
  }

  Future<void> _handleTokenRefresh(String newToken) async {
    print('🔄 Token refreshed: $newToken');
    fcmToken.value = newToken;

    final storageService = Get.find<StorageService>();
    await storageService.setString('fcm_token', newToken);

    // Update on server if user is logged in
    await _updateTokenOnServer(newToken);
  }

  Future<void> _updateTokenOnServer(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      try {
        final userData = json.decode(userDataString);
        final userId = userData['id'];
        final authToken = prefs.getString('auth_token');

        if (userId != null && authToken != null) {
          final apiService = Get.find<ApiService>();
          await apiService.updateDeviceToken(
            userId: userId,
            newToken: token,
            authToken: authToken,
          );
          print('✅ Token updated on server');
        }
      } catch (e) {
        print('❌ Error updating token: $e');
      }
    }
  }

  Future<void> registerTokenOnLogin(int userId, String authToken) async {
    if (fcmToken.value.isNotEmpty) {
      try {
        final apiService = Get.find<ApiService>();
        await apiService.registerDeviceToken(
          userId: userId,
          deviceToken: fcmToken.value,
          deviceType: GetPlatform.isIOS ? 'ios' : 'android',
          authToken: authToken,
        );
        print('✅ Token registered for user: $userId');
      } catch (e) {
        print('❌ Error registering token: $e');
      }
    }
  }

  Future<void> removeTokenOnLogout(int userId, String authToken) async {
    try {
      final apiService = Get.find<ApiService>();
      await apiService.removeDeviceToken(
        userId: userId,
        authToken: authToken,
      );
      print('✅ Token removed for user: $userId');
    } catch (e) {
      print('❌ Error removing token: $e');
    }
  }

  void _showInAppNotification(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? 'general';

    Color bgColor = Colors.blue;
    IconData icon = Icons.notifications;

    switch (type) {
      case 'order_status':
        bgColor = Colors.green;
        icon = Icons.shopping_cart;
        break;
      case 'promotion':
        bgColor = Colors.orange;
        icon = Icons.local_offer;
        break;
      case 'alert':
        bgColor = Colors.red;
        icon = Icons.warning;
        break;
    }

    Get.snackbar(
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: bgColor,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      onTap: (snack) {
        _navigateFromNotification(data);
      },
    );
  }

  void _navigateFromNotification(Map<String, dynamic> data) {
    final String? type = data['type'];
    final String? orderId = data['order_id']?.toString() ?? data['orderId']?.toString();
    final String? productId = data['product_id']?.toString() ?? data['productId']?.toString();

    if (type == 'order_status' && orderId != null) {
      Get.toNamed('/order-details', arguments: {'orderId': orderId});
    } else if (type == 'new_order' && orderId != null) {
      Get.toNamed('/order-details', arguments: {'orderId': orderId});
    } else if (type == 'product_update' && productId != null) {
      Get.toNamed('/product-details', arguments: {'productId': productId});
    } else {
      Get.toNamed('/notifications');
    }
  }

  int incrementUnreadCount() => unreadCount.value++;
  int resetUnreadCount() => unreadCount.value = 0;
}