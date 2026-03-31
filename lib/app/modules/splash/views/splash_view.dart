import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashView extends StatelessWidget {
  SplashView({Key? key}) : super(key: key) {
    _initializeApp();
  }

  void _initializeApp() async {
    // Initialize GetStorage
    await GetStorage.init();

    // Check authentication status
    final storage = GetStorage();
    final token = storage.read('auth_token');

    await Future.delayed(const Duration(seconds: 2));

    if (token != null) {
      Get.offNamed('/home');
    } else {
      Get.offNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF111261), Color(0xFF0B630B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.business_center,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MediSupply Pro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111261),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wholesale Medical Supplies',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFF0B630B),
            ),
          ],
        ),
      ),
    );
  }
}