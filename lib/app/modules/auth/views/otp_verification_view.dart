// lib/app/modules/auth/views/otp_verification_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../controllers/auth_controller.dart';
import 'reset_password_view.dart';

class OtpVerificationView extends StatefulWidget {
  final String email;

  const OtpVerificationView({Key? key, required this.email})
      : super(key: key);

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final AuthController controller = Get.find<AuthController>();
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    controller.startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _resendOtp() {
    controller.resendOtp(widget.email);
    _otpController.clear();
  }

  void _verifyOtp() async {
    if (_otpController.text.length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter a valid 6-digit OTP',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final success = await controller.verifyOtp(
        widget.email,
        _otpController.text
    );

    if (success) {
      Get.to(() => ResetPasswordView(email: widget.email));
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111261),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade400,
            width: 2,
          ),
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF0B630B),
            width: 3,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111261)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildEmailInfo(),
              const SizedBox(height: 40),
              _buildOtpField(defaultPinTheme, focusedPinTheme),
              const SizedBox(height: 24),
              _buildTimerAndResend(),
              const SizedBox(height: 32),
              _buildVerifyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B630B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.sms,
            size: 32,
            color: Color(0xFF0B630B),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111261),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111261).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, color: Color(0xFF111261), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111261),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Change',
              style: TextStyle(
                color: Color(0xFF0B630B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField(PinTheme defaultTheme, PinTheme focusedTheme) {
    return Center(
      child: Pinput(
        controller: _otpController,
        length: 6,
        keyboardType: TextInputType.number,
        defaultPinTheme: defaultTheme,
        focusedPinTheme: focusedTheme,
        onCompleted: (value) {
          // Auto verify when complete
          _verifyOtp();
        },
      ),
    );
  }

  Widget _buildTimerAndResend() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.timer, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              controller.secondsRemaining.value > 0
                  ? 'Resend in ${controller.secondsRemaining.value}s'
                  : 'Didn\'t receive OTP?',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        if (controller.canResend.value)
          TextButton(
            onPressed: controller.isResendLoading.value ? null : _resendOtp,
            child: controller.isResendLoading.value
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B630B)),
              ),
            )
                : const Text(
              'Resend OTP',
              style: TextStyle(
                color: Color(0xFF0B630B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    ));
  }

  Widget _buildVerifyButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.isOtpLoading.value ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B630B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: controller.isOtpLoading.value
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ));
  }
}