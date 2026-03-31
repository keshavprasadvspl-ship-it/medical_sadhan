import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/support_model.dart';
import '../controllers/help_support_controller.dart';


class HelpSupportView extends GetView<HelpSupportController> {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              // Tab Bar
              Container(
                color: Colors.white,
                child: const TabBar(
                  labelColor: Color(0xFF0B630B),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF0B630B),
                  tabs: [
                    Tab(text: 'FAQs'),
                    Tab(text: 'Contact'),
                    Tab(text: 'Tickets'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  children: [
                    _buildFAQsTab(),
                    _buildContactTab(),
                    _buildTicketsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showCreateTicketDialog,
        backgroundColor: const Color(0xFF0B630B),
        icon: const Icon(Icons.support_agent, color: Colors.white),
        label: const Text('Get Help', style: TextStyle(color: Colors.white)),
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
            'Help & Support',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF111261)),
            onPressed: () {
              // Implement search
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAQsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoading();
      }

      return Column(
        children: [
          // Category Filter
          _buildCategoryFilter(),

          // FAQs List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.getFilteredFAQs().length,
              itemBuilder: (context, index) {
                final faq = controller.getFilteredFAQs()[index];
                return _buildFAQCard(faq);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: controller.getFAQCategories().map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: controller.selectedCategory.value == category,
                onSelected: (_) => controller.updateCategory(category),
                selectedColor: const Color(0xFF0B630B).withOpacity(0.2),
                labelStyle: TextStyle(
                  color: controller.selectedCategory.value == category
                      ? const Color(0xFF0B630B)
                      : Colors.grey,
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  Widget _buildFAQCard(FAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: Key(faq.id),
          initiallyExpanded: faq.isExpanded,
          onExpansionChanged: (expanded) => controller.toggleFAQ(faq.id),
          title: Text(
            faq.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111261),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq.answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Contact Cards
        Column(
          children: controller.supportContacts.map((contact) {
            return _buildContactCard(contact);
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Business Hours
        _buildBusinessHoursCard(),

        const SizedBox(height: 24),

        // Emergency Section
        _buildEmergencyCard(),
      ],
    );
  }

  Widget _buildContactCard(SupportContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: contact.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            _getContactIcon(contact.icon),
            color: contact.color,
          ),
        ),
        title: Text(
          contact.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF111261),
          ),
        ),
        subtitle: Text(contact.value),
        trailing: IconButton(
          icon: Icon(
            _getActionIcon(contact.type),
            color: contact.color,
          ),
          onPressed: () => _handleContactAction(contact),
        ),
      ),
    );
  }

  Widget _buildBusinessHoursCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111261),
              ),
            ),
            const SizedBox(height: 12),
            _buildBusinessHourRow('Monday - Saturday', '8:00 AM - 10:00 PM'),
            _buildBusinessHourRow('Sunday', '9:00 AM - 8:00 PM'),
            _buildBusinessHourRow('Emergency Support', '24/7'),
            _buildBusinessHourRow('Email Support', 'Always Available'),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHourRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B630B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Emergency Medical Support',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'For critical medical emergencies requiring immediate attention:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildEmergencyContact('Emergency Hotline', '108'),
            _buildEmergencyContact('Ambulance', '102'),
            _buildEmergencyContact('Police', '100'),
            const SizedBox(height: 12),
            const Text(
              'Note: Please contact emergency services directly for life-threatening situations.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(String service, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              service,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            number,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.red),
            onPressed: () => controller.makeCall(number),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsTab() {
    return Obx(() {
      if (controller.supportTickets.isEmpty) {
        return _buildNoTickets();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.supportTickets.length,
        itemBuilder: (context, index) {
          final ticket = controller.supportTickets[index];
          return _buildTicketCard(ticket);
        },
      );
    });
  }

  Widget _buildTicketCard(SupportTicket ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111261),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ticket.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ticket.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(ticket.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Category and Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(ticket.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              ticket.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            if (ticket.resolution != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resolution:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(ticket.resolution!),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // View Details Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Show ticket details
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111261),
                  side: const BorderSide(color: Color(0xFF111261)),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTickets() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_tickets.png',
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
                  Icons.support_agent_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'No Support Tickets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a ticket to get help with any issues',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
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

  IconData _getContactIcon(String icon) {
    switch (icon) {
      case 'call':
        return Icons.phone;
      case 'mail':
        return Icons.email;
      case 'chat':
        return Icons.chat;
      case 'forum':
        return Icons.forum;
      default:
        return Icons.help;
    }
  }

  IconData _getActionIcon(String type) {
    switch (type) {
      case 'phone':
        return Icons.call;
      case 'email':
        return Icons.email;
      case 'whatsapp':
        return Icons.message;
      case 'chat':
        return Icons.chat_bubble;
      default:
        return Icons.arrow_forward;
    }
  }

  void _handleContactAction(SupportContact contact) {
    switch (contact.type) {
      case 'phone':
        controller.makeCall(contact.value);
        break;
      case 'email':
        controller.sendEmail(contact.value);
        break;
      case 'whatsapp':
        controller.openWhatsApp(contact.value);
        break;
      case 'chat':
        controller.startLiveChat();
        break;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Just now';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}