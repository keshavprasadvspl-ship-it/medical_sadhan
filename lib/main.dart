import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:medical_b2b_app/app/global_widgets/cart_floating_widgets.dart';
import 'package:medical_b2b_app/app/global_widgets/controller/agency_controller.dart';
import 'package:medical_b2b_app/app/modules/main/controllers/main_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/data/providers/api_provider.dart';
import 'app/data/providers/cart_service.dart';
import 'app/routes/app_pages.dart';
import 'app/core/theme/app_theme.dart';
import 'app/services/connectivity_service.dart';
import 'app/services/storage_service.dart';
import 'app/core/widgets/offline_wrapper.dart'; // Add this import
import 'firebase_options.dart';

// Initialize local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase in background isolate
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('📱 Background message received: ${message.messageId}');
  print('📊 Background data: ${message.data}');

  if (message.notification != null) {
    print('🔔 Background notification: ${message.notification?.title}');
  }
}

// Initialize local notifications
Future<void> _initializeLocalNotifications() async {
  // Android initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS initialization
  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Handle notification tap
      if (response.payload != null) {
        try {
          final data = json.decode(response.payload!);
          print('🔔 Local notification tapped: $data');

          // Navigate based on notification data
          final String? type = data['type'] as String?;
          final String? orderId = data['orderId'] as String?;

          if (type == 'order_status' && orderId != null) {
            Get.toNamed(Routes.ORDERS, arguments: orderId);
          }
        } catch (e) {
          print('❌ Error handling notification tap: $e');
        }
      }
    },
  );

  // Create notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// Show local notification
Future<void> _showLocalNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
    id: message.hashCode,
    title: message.notification?.title ?? 'New Notification',
    body: message.notification?.body ?? 'You have a new notification',
    notificationDetails: platformChannelSpecifics,
    payload: json.encode(message.data),
  );

}

// Setup notification listeners
Future<void> _setupNotificationListeners() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ User granted permission');

    // Get FCM token
    String? token = await messaging.getToken();
    print('📱 FCM Token: $token');

// Save token to storage
    if (token != null) {
      final storageService = Get.find<StorageService>();
      await storageService.setString('fcm_token', token);

      // Store on server if user is already logged in
      await _storeFCMTokenOnServer(token);
    }
  }

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📨 Foreground message received!');

    if (message.notification != null) {
      print('🔔 Title: ${message.notification?.title}');
      print('🔔 Body: ${message.notification?.body}');

      // Show local notification
      _showLocalNotification(message);

      // Show in-app notification
      Get.snackbar(
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? '',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  });

  // Handle when user taps notification and app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('👆 Notification opened app from background!');
    _handleNotificationTap(message);
  });

  // Check for initial message (app opened from terminated state)
  RemoteMessage? initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    print('🚀 App launched from terminated state via notification!');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationTap(initialMessage);
    });
  }

  // Listen for token refresh
// Listen for token refresh
  messaging.onTokenRefresh.listen((newToken) async {
    print('🔄 FCM Token refreshed: $newToken');
    final storageService = Get.find<StorageService>();
    await storageService.setString('fcm_token', newToken);

    // Also update on server if user is logged in
    await _storeFCMTokenOnServer(newToken);
  });
}

// Handle notification tap
void _handleNotificationTap(RemoteMessage message) {
  print('👆 Handling notification tap');
  final Map<String, dynamic> data = message.data;

  final String? type = data['type'] as String?;
  final String? orderId = data['orderId'] as String?;

  if (type == 'order_status' && orderId != null) {
    Get.toNamed(Routes.ORDERS, arguments: orderId);
  }
}


// Add this new function to store token on server when user is logged in
Future<void> _storeFCMTokenOnServer(String token) async {
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
          deviceToken: token,
          deviceType: GetPlatform.isIOS ? 'ios' : 'android',
          authToken: authToken,
        );
        print('✅ FCM token stored on server for user: $userId');
      }
    } catch (e) {
      print('❌ Error storing FCM token: $e');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local notifications
  await _initializeLocalNotifications();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize ConnectivityService
  final connectivityService = ConnectivityService();
  Get.put(connectivityService, permanent: true);

  // Initialize StorageService first
  final storageService = StorageService();
  Get.put(storageService, permanent: true);

  // Initialize other services
  Get.put(ApiService(), permanent: true);
  Get.put(CartService(), permanent: true);
  Get.put(MainController(), permanent: true);
  Get.put(GlobalController());

  final prefs = await SharedPreferences.getInstance();
  await GetStorage.init();

  String initialRoute = Routes.MAIN;

  final token = prefs.getString('auth_token');
  final userDataString = prefs.getString('user_data');

  if (token != null && userDataString != null) {
    try {
      final userData = userDataString.isNotEmpty
          ? Map<String, dynamic>.from(json.decode(userDataString))
          : {};
      print(userData);
      final userType = userData['type'] ?? '';

      if (userType == 'buyer') {
        initialRoute = Routes.MAIN;
      } else if (userType == 'vendor') {
        initialRoute = Routes.VENDERS_DASHBOARD;
      } else {
        initialRoute = Routes.LOGIN;
      }
    } catch (e) {
      initialRoute = Routes.LOGIN;
    }
  }

  // Check initial connectivity
  await connectivityService.checkConnectivity();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Setup notification listeners after app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Medicine App',
      debugShowCheckedModeBanner: false,
       
      theme: AppTheme.light,
      initialRoute: widget.initialRoute,
      getPages: AppPages.routes,
builder: (context, child) {
  final controller = Get.find<MainController>();

  return OfflineWrapper(
    onRetry: () {
      print('Retrying connection...');
    },
    child: Stack(
      children: [
        child!, // ✅ main app

        // 🔥 GLOBAL FLOATING CART
        Obx(() {
          // Cart screen pe hide karo (index 2)
          if (controller.currentIndex.value == 2) return const SizedBox.shrink();
          // ✅ SIRF isCartVisible check — cartCount check HATAO
          if (!controller.isCartVisible.value) return const SizedBox.shrink();

          return const FloatingCartWidget();
        }),
      ],
    ),
  );
},    );
    
  }
}