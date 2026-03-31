import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            // Settings List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader('Push Notifications'),
                  _buildNotificationToggle('Order Updates', true),
                  _buildNotificationToggle('Promotions & Offers', true),
                  _buildNotificationToggle('Delivery Updates', true),
                  _buildNotificationToggle('Payment Notifications', true),
                  _buildNotificationToggle('Prescription Reminders', true),
                  _buildNotificationToggle('Security Alerts', true),
                  _buildNotificationToggle('System Updates', false),

                  _buildSectionHeader('Notification Preferences'),
                  _buildSoundToggle('Notification Sound', true),
                  _buildSoundToggle('Vibration', true),
                  _buildSoundToggle('LED Light', false),

                  _buildSectionHeader('Scheduled Notifications'),
                  _buildTimePreference('Quiet Hours', '10:00 PM - 7:00 AM'),
                  _buildTimePreference('Daily Summary Time', '8:00 PM'),

                  _buildSectionHeader('Advanced'),
                  _buildPreferenceItem('Notification History', Icons.history),
                  _buildPreferenceItem('Clear All Notifications', Icons.delete_sweep),
                  _buildPreferenceItem('Export Notifications', Icons.download),

                  const SizedBox(height: 40),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Settings Saved',
                        'Notification preferences updated',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF0B630B),
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B630B),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Save Settings'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF111261)),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Notification Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111261),
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(String title, bool value) {
    bool isEnabled = value;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title),
        trailing: Switch(
          value: isEnabled,
          onChanged: (newValue) {
            isEnabled = newValue;
          },
          activeColor: const Color(0xFF0B630B),
        ),
      ),
    );
  }

  Widget _buildSoundToggle(String title, bool value) {
    bool isEnabled = value;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title),
        trailing: Switch(
          value: isEnabled,
          onChanged: (newValue) {
            isEnabled = newValue;
          },
          activeColor: const Color(0xFF0B630B),
        ),
      ),
    );
  }

  Widget _buildTimePreference(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Show time picker
          _showTimePicker(title);
        },
      ),
    );
  }

  Widget _buildPreferenceItem(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF111261)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          if (title == 'Clear All Notifications') {
            Get.defaultDialog(
              title: 'Clear All Notifications',
              content: const Text('Are you sure you want to clear all notifications?'),
              textConfirm: 'Clear',
              textCancel: 'Cancel',
              confirmTextColor: Colors.white,
              onConfirm: () {
                Get.back();
                Get.snackbar(
                  'Cleared',
                  'All notifications cleared',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showTimePicker(String title) {
    showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    ).then((selectedTime) {
      if (selectedTime != null) {
        Get.snackbar(
          '$title Updated',
          'Set to ${selectedTime.format(Get.context!)}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }
}