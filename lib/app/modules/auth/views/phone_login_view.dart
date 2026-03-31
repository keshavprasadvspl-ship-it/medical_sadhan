import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class PhoneLoginView extends StatelessWidget {
  PhoneLoginView({super.key});

  final AuthController controller = Get.find<AuthController>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Login with Phone"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111261),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            const Text(
              "Enter your phone number",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111261),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "We will send an OTP for verification",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 30),

            /// PHONE FIELD
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// OTP FIELD
            Obx(() {

              if (!controller.phoneOtpSent.value) {
                return const SizedBox();
              }

              return Column(
                children: [

                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      labelText: "Enter 6 Digit OTP",
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// RESEND OTP
                  Obx(() {

                    if (controller.canResend.value) {

                      return TextButton(
                        onPressed: () async {

                          if (phoneController.text.length != 10) {
                            Get.snackbar(
                              "Error",
                              "Phone number must be 10 digits",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          await controller.sendPhoneOtp(
                            phoneController.text.trim(),
                          );

                          controller.startResendTimer();

                        },
                        child: const Text(
                          "Resend OTP",
                          style: TextStyle(
                            color: Color(0xFF0B630B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return Text(
                      "Resend OTP in ${controller.secondsRemaining.value}s",
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    );

                  }),

                  const SizedBox(height: 10),
                ],
              );
            }),

            const SizedBox(height: 20),

            /// BUTTON
            Obx(() {

              return SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  onPressed: controller.phoneLoginLoading.value
                      ? null
                      : controller.phoneOtpSent.value
                      ? () {

                    if (otpController.text.length != 6) {
                      Get.snackbar(
                        "Error",
                        "OTP must be 6 digits",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    controller.verifyPhoneOtp(
                      phone: phoneController.text.trim(),
                      otp: otpController.text.trim(),
                    );

                  }
                      : () async {

                    if (phoneController.text.length != 10) {
                      Get.snackbar(
                        "Error",
                        "Phone number must be 10 digits",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    final success = await controller.sendPhoneOtp(
                      phoneController.text.trim(),
                    );

                    if (success) {
                      controller.startResendTimer();
                    }

                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B630B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: controller.phoneLoginLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    controller.phoneOtpSent.value
                        ? "Verify OTP"
                        : "Send OTP",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );

            }),

          ],
        ),
      ),
    );
  }
}