// lib/app/modules/notifications/controllers/notifications_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/providers/api_endpoints.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final filteredNotifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMoreData = true.obs;
  final selectedFilter = 'All'.obs;
  final searchQuery = ''.obs;
  final showArchived = false.obs;
  final unreadCount = 0.obs;

  // Pagination
  final currentPage = 1.obs;
  final perPage = 20.obs;
  final totalNotifications = 0.obs;

  // Search controller
  final searchController = TextEditingController();

  // Vendor ID
  late SharedPreferences _prefs;
  final userId = 0.obs;

  // Auto-refresh
  Timer? _refreshTimer;

  // Filter options
  final filterOptions = [
    'All',
    'Unread',
    'test',
    'order',
    'promotion',
    'delivery',
    'payment',
    'prescription',
    'system',
    'security',
    'reminder',
  ];

  @override
  void onInit() {
    super.onInit();
    initializePrefs();

    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      filterNotifications();
    });

    // Debounce search
    debounce(
      searchQuery,
          (_) => filterNotifications(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    _refreshTimer?.cancel();
    super.onClose();
  }

  Future<void> initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    loadUserId();
    await fetchNotifications(reset: true);
    startAutoRefresh();
  }

  void loadUserId() {
    final userDataString = _prefs.getString('user_data');
    if (userDataString != null && userDataString.isNotEmpty) {
      final userData = json.decode(userDataString);
      final id = userData['id'] ?? userData['user_id'] ?? userData['vendor_id'];
      userId.value = int.tryParse(id.toString()) ?? 0;
      print('User ID loaded: ${userId.value}');
    }
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!isLoading.value && !isLoadingMore.value) {
        fetchNotifications(reset: true, showLoader: false);
      }
    });
  }

  Future<void> fetchNotifications({bool reset = false, bool showLoader = true}) async {
    if (reset) {
      currentPage.value = 1;
      notifications.clear();
      filteredNotifications.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || (isLoading.value && !reset)) return;

    try {
      if (showLoader) {
        if (reset) {
          isLoading.value = true;
        } else {
          isLoadingMore.value = true;
        }
      }

      final uri = Uri.parse('${ApiEndpoints.baseUrl}/notifications/${userId.value}')
          .replace(queryParameters: {
        'page': currentPage.value.toString(),
        'per_page': perPage.value.toString(),
      });

      print('Fetching notifications from: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          final data = jsonData['data'];

          List<dynamic> notificationsJson = [];
          if (data is Map && data.containsKey('data')) {
            notificationsJson = data['data'] as List<dynamic>;
            totalNotifications.value = data['total'] ?? 0;
            hasMoreData.value = (data['current_page'] ?? 1) < (data['last_page'] ?? 1);
          } else if (data is List) {
            notificationsJson = data;
            totalNotifications.value = notificationsJson.length;
            hasMoreData.value = false;
          }

          final newNotifications = notificationsJson.map((json) =>
              NotificationModel.fromJson(json)).toList();

          if (reset) {
            notifications.value = newNotifications;
          } else {
            notifications.addAll(newNotifications);
          }

          // Apply current filter
          filterNotifications();
          updateUnreadCount();

          print('Loaded ${newNotifications.length} notifications');
        }
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      if (notifications.isEmpty) {
        Get.snackbar(
          'Error',
          'Failed to load notifications',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void loadMoreNotifications() {
    if (hasMoreData.value && !isLoadingMore.value && !isLoading.value) {
      currentPage.value++;
      fetchNotifications(reset: false);
    }
  }

  void filterNotifications() {
    var filtered = notifications.where((notification) => !notification.isArchived).toList();

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((notification) {
        return notification.title.toLowerCase().contains(query) ||
            notification.message.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by selected filter
    if (selectedFilter.value != 'All') {
      if (selectedFilter.value == 'Unread') {
        filtered = filtered.where((notification) => !notification.isRead).toList();
      } else {
        filtered = filtered.where((notification) =>
        notification.type.toLowerCase() == selectedFilter.value.toLowerCase()).toList();
      }
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    filteredNotifications.assignAll(filtered);
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    filterNotifications();
  }

  void toggleShowArchived() {
    showArchived.value = !showArchived.value;

    if (showArchived.value) {
      // Show archived notifications
      var archived = notifications.where((notification) => notification.isArchived).toList();
      archived.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      filteredNotifications.assignAll(archived);
    } else {
      // Show non-archived notifications
      filterNotifications();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/notifications/$id/read'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId.value}),
      );

      if (response.statusCode == 200) {
        final index = notifications.indexWhere((notification) => notification.id == id);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          filterNotifications();
          updateUnreadCount();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/notifications/read-all'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId.value}),
      );

      if (response.statusCode == 200) {
        for (int i = 0; i < notifications.length; i++) {
          if (!notifications[i].isRead && !notifications[i].isArchived) {
            notifications[i] = notifications[i].copyWith(isRead: true);
          }
        }
        filterNotifications();
        updateUnreadCount();

        Get.snackbar(
          'All Read',
          'All notifications marked as read',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0B630B),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    if (notifications.isEmpty) return;

    Get.defaultDialog(
      title: 'Clear All Notifications',
      content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
      textConfirm: 'Clear All',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        try {
          final response = await http.delete(
            Uri.parse('${ApiEndpoints.baseUrl}/notifications/clear-all'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'user_id': userId.value}),
          );

          if (response.statusCode == 200) {
            notifications.clear();
            filteredNotifications.clear();
            updateUnreadCount();
            Get.back();

            Get.snackbar(
              'Cleared',
              'All notifications cleared',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          print('Error clearing notifications: $e');
        }
      },
    );
  }

  void archiveNotification(int id) {
    final index = notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isArchived: true);
      filterNotifications();
      updateUnreadCount();

      Get.snackbar(
        'Archived',
        'Notification moved to archive',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void unarchiveNotification(int id) {
    final index = notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isArchived: false);
      if (showArchived.value) {
        toggleShowArchived();
      } else {
        filterNotifications();
      }

      Get.snackbar(
        'Unarchived',
        'Notification restored',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteNotification(int id) {
    final notification = notifications.firstWhere((n) => n.id == id);

    Get.defaultDialog(
      title: 'Delete Notification',
      content: Column(
        children: [
          const Text('Are you sure you want to delete this notification?'),
          const SizedBox(height: 10),
          Text(
            notification.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        try {
          final response = await http.delete(
            Uri.parse('${ApiEndpoints.baseUrl}/notifications/${notification.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'user_id': userId.value}),
          );

          if (response.statusCode == 200) {
            notifications.removeWhere((n) => n.id == id);
            filterNotifications();
            updateUnreadCount();
            Get.back();

            Get.snackbar(
              'Deleted',
              'Notification deleted successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          print('Error deleting notification: $e');
        }
      },
    );
  }

  void handleNotificationTap(NotificationModel notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on type or show details
    showNotificationDetails(notification);
  }

  void showNotificationDetails(NotificationModel notification) {
    Get.bottomSheet(
      _buildNotificationDetails(notification),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildNotificationDetails(NotificationModel notification) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Notification Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  notification.typeIcon,
                  color: notification.typeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111261),
                      ),
                    ),
                    Text(
                      notification.detailedTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Priority Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: notification.priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: notification.priorityColor,
                ),
                const SizedBox(width: 6),
                Text(
                  notification.priority.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: notification.priorityColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Message
          Text(
            notification.message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          if (notification.data != null && notification.data!.isNotEmpty) ...[
            const Text(
              'Additional Information:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...notification.data!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    if (notification.isArchived) {
                      unarchiveNotification(notification.id);
                    } else {
                      archiveNotification(notification.id);
                    }
                  },
                  child: Text(
                    notification.isArchived ? 'Unarchive' : 'Archive',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    // Add navigation logic here based on notification type
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B630B),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void updateUnreadCount() {
    unreadCount.value = notifications.where(
            (notification) => !notification.isRead && !notification.isArchived
    ).length;
  }

  List<NotificationModel> getUnreadNotifications() {
    return notifications.where(
            (notification) => !notification.isRead && !notification.isArchived
    ).toList();
  }

  List<NotificationModel> getNotificationsByType(String type) {
    return notifications.where(
            (notification) => notification.type == type && !notification.isArchived
    ).toList();
  }

  void testNotification() {
    // For testing only - remove in production
    final testNotification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: userId.value,
      type: 'test',
      title: '🧪 Test Notification',
      message: 'This is a test notification from your API',
      data: {
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
      },
      isRead: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      sentStatus: 'sent',
    );

    notifications.insert(0, testNotification);
    filterNotifications();
    updateUnreadCount();

    Get.snackbar(
      'Test Notification',
      'New test notification added',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showFilterOptions() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.80,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Filter Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111261),
                ),
              ),
              const SizedBox(height: 20),
              ...filterOptions.map((filter) {
                return Obx(() => ListTile(
                  title: Text(filter[0].toUpperCase() + filter.substring(1)),
                  trailing: selectedFilter.value == filter
                      ? const Icon(Icons.check, color: Color(0xFF0B630B))
                      : null,
                  onTap: () {
                    updateFilter(filter);
                    Get.back();
                  },
                ));
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}