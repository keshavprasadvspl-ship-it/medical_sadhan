import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Quick Actions Bar
            _buildQuickActions(),

            // Notifications List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoading();
                }

                if (controller.filteredNotifications.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildNotificationsList();
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.testNotification,
        backgroundColor: const Color(0xFF0B630B),
        child: const Icon(Icons.notification_add, color: Colors.white),
        tooltip: 'Test Notification',
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
          Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111261),
                ),
              ),
              Text(
                '${controller.unreadCount.value} unread',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          )),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF111261)),
            onPressed: () {
              // Show search
              _showSearchSheet();
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF111261)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Color(0xFF111261)),
                    SizedBox(width: 8),
                    Text('Notification Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.notification_add, color: Color(0xFF111261)),
                    SizedBox(width: 8),
                    Text('Test Notification'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                Get.toNamed('/notifications-setting');
              } else if (value == 'test') {
                controller.testNotification();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          // Filter Button
          Obx(() => OutlinedButton.icon(
            onPressed: controller.showFilterOptions,
            icon: const Icon(Icons.filter_list, size: 16),
            label: Text(controller.selectedFilter.value),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF111261),
              side: const BorderSide(color: Color(0xFF111261)),
            ),
          )),

          const SizedBox(width: 8),

          // Archive Toggle
          Obx(() => OutlinedButton.icon(
            onPressed: controller.toggleShowArchived,
            icon: Icon(
              controller.showArchived.value ? Icons.unarchive : Icons.archive,
              size: 16,
            ),
            label: Text(''),
            // label: Text(controller.showArchived.value ? 'Archived' : 'Archive'),
            style: OutlinedButton.styleFrom(
              foregroundColor: controller.showArchived.value ? Colors.orange : const Color(0xFF111261),
              side: BorderSide(
                color: controller.showArchived.value ? Colors.orange : const Color(0xFF111261),
              ),
            ),
          )),

          const Spacer(),

          // Mark All Read
          Obx(() => controller.unreadCount.value > 0
              ? TextButton.icon(
            onPressed: controller.markAllAsRead,
            icon: const Icon(Icons.mark_email_read, size: 16),
            label: const Text('Mark All Read'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0B630B),
            ),
          )
              : const SizedBox()),

          // Clear All
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: controller.clearAllNotifications,
            tooltip: 'Clear All',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchNotifications(reset: true);
      },
      color: const Color(0xFF0B630B),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!controller.isLoadingMore.value &&
              scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            controller.loadMoreNotifications();
          }
          return true;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredNotifications.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.filteredNotifications.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final notification = controller.filteredNotifications[index];
            return _buildNotificationCard(notification);
          },
        ),
      ),
    );
  }


  Widget _buildNotificationCard(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: notification.isArchived ? Colors.blue : Colors.orange,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(
          notification.isArchived ? Icons.unarchive : Icons.archive,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Archive/Unarchive
          if (notification.isArchived) {
            controller.unarchiveNotification(notification.id);
          } else {
            controller.archiveNotification(notification.id);
          }
          return false;
        } else {
          // Delete
          controller.deleteNotification(notification.id);
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: notification.isRead ? Colors.white : Colors.blue[50],
        child: InkWell(
          onTap: () => controller.handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
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

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111261),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                notification.formattedTime,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (notification.priority == NotificationPriority.urgent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: notification.priorityColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'URGENT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: notification.priorityColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Message
                      Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Footer
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: notification.typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              notification.typeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: notification.typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const Spacer(),

                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),

                          if (notification.isArchived)
                            const Icon(
                              Icons.archive,
                              size: 14,
                              color: Colors.orange,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF0B630B),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_notifications.png',
            height: 150,
            width: 150,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            controller.showArchived.value ? 'No Archived Notifications' : 'No Notifications',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.showArchived.value
                ? 'Archived notifications will appear here'
                : 'You\'re all caught up! New notifications will appear here',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (!controller.showArchived.value)
            ElevatedButton(
              onPressed: controller.testNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B630B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Test Notification'),
            ),
        ],
      ),
    );
  }

  void _showSearchSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
              'Search Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111261),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Search by title or message...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.searchController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}