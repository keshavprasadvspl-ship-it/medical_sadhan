// lib/app/core/widgets/offline_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/connectivity_service.dart';

class OfflineScreen extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const OfflineScreen({
    Key? key,
    required this.child,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Obx(() {
      if (connectivityService.isConnected.value) {
        return child;
      } else {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Offline illustration
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 60,
                      color: Colors.red.shade400,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Offline text
                  Text(
                    'No Internet Connection',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Please check your internet connection and try again',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Retry button
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (onRetry != null) {
                        onRetry!();
                      } else {
                        // Check connectivity again
                        await connectivityService.checkConnectivity();
                        if (connectivityService.isConnected.value) {
                          // Refresh current page
                          final currentRoute = Get.currentRoute;
                          if (currentRoute.isNotEmpty) {
                            Get.offAllNamed(currentRoute);
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });
  }
}