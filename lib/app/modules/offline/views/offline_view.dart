// lib/app/modules/offline/offline_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/connectivity_service.dart';

class OfflineView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'No Internet Connection',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please check your internet connection and try again',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Obx(() => connectivityService.isConnected.value
                  ? const SizedBox()
                  : ElevatedButton(
                onPressed: () async {
                  await connectivityService.checkConnectivity();
                  if (connectivityService.isConnected.value) {
                    Get.offAllNamed(Routes.MAIN);
                  }
                },
                child: const Text('Retry'),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}