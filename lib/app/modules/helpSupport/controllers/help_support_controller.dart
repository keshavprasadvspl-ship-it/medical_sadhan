import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/support_model.dart';

class HelpSupportController extends GetxController {
  final faqs = <FAQ>[].obs;
  final supportContacts = <SupportContact>[].obs;
  final supportTickets = <SupportTicket>[].obs;
  final isLoading = false.obs;
  final selectedCategory = 'All'.obs;

  // Form controllers
  final ticketTitleController = TextEditingController();
  final ticketDescriptionController = TextEditingController();
  final ticketCategoryController = TextEditingController();
  final searchController = TextEditingController();

  // Ticket categories
  final ticketCategories = [
    'Order Issues',
    'Payment Problems',
    'Delivery & Shipping',
    'Product Quality',
    'Account Issues',
    'Technical Support',
    'Refund & Return',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    loadFAQs();
    loadSupportContacts();
    loadSupportTickets();
  }

  @override
  void onClose() {
    ticketTitleController.dispose();
    ticketDescriptionController.dispose();
    ticketCategoryController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadFAQs() async {
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 1));

    faqs.assignAll([
      FAQ(
        id: '1',
        question: 'How do I place an order?',
        answer: 'To place an order:\n1. Browse vendors_products and add them to cart\n2. Go to cart and click "Proceed to Checkout"\n3. Select delivery address\n4. Choose payment method\n5. Review and confirm order\nYou will receive order confirmation via email and SMS.',
        category: 'Ordering',
      ),
      FAQ(
        id: '2',
        question: 'What payment methods do you accept?',
        answer: 'We accept:\n• Credit/Debit Cards (Visa, MasterCard, RuPay)\n• Net Banking\n• UPI (Google Pay, PhonePe, Paytm)\n• Cash on Delivery (for select areas)\n• Wallet Payments',
        category: 'Payment',
      ),
      FAQ(
        id: '3',
        question: 'How long does delivery take?',
        answer: 'Delivery time varies by location:\n• Metro cities: 2-3 business days\n• Tier 1 cities: 3-5 business days\n• Tier 2/3 cities: 5-7 business days\n• Remote areas: 7-10 business days\nYou can track your order in real-time from the Orders section.',
        category: 'Delivery',
      ),
      FAQ(
        id: '4',
        question: 'Can I cancel my order?',
        answer: 'Yes, you can cancel orders within specific time frames:\n• Before processing: Full refund\n• During processing: Partial refund\n• After shipping: Cannot cancel\nGo to Orders → Select order → Cancel Order.',
        category: 'Cancellation',
      ),
      FAQ(
        id: '5',
        question: 'How do I return a product?',
        answer: 'Return process:\n1. Go to Orders → Select order\n2. Click "Return Item"\n3. Select reason and upload photos\n4. Schedule pickup\n5. Get refund after quality check\nReturns accepted within 7 days of delivery.',
        category: 'Returns',
      ),
      FAQ(
        id: '6',
        question: 'Are medicines genuine?',
        answer: 'Yes! We guarantee:\n• 100% genuine medicines\n• Sourced directly from manufacturers\n• Stored in temperature-controlled facilities\n• Proper expiry dates checked\n• All medicines are licensed and approved.',
        category: 'Quality',
      ),
      FAQ(
        id: '7',
        question: 'Do I need a prescription?',
        answer: 'For prescription medicines (Rx):\n• Upload prescription during checkout\n• Prescription must be valid\n• Doctor details must be clear\n• Prescription should not be expired\nFor OTC medicines: No prescription needed.',
        category: 'Prescription',
      ),
      FAQ(
        id: '8',
        question: 'How do I track my order?',
        answer: 'Track your order:\n1. Go to Orders section\n2. Select the order\n3. Click "Track Order"\n4. View real-time updates\nYou will also receive SMS/email updates.',
        category: 'Tracking',
      ),
      FAQ(
        id: '9',
        question: 'What are your business hours?',
        answer: 'Customer support hours:\n• Monday to Saturday: 8 AM to 10 PM\n• Sunday: 9 AM to 8 PM\n• Emergency support: 24/7 for critical medicines\n• Email support: Always available',
        category: 'Support',
      ),
      FAQ(
        id: '10',
        question: 'How do I contact customer support?',
        answer: 'Multiple ways to contact us:\n• Call: 1800-123-4567\n• Email: support@medicalb2b.com\n• Live Chat: Available on app\n• WhatsApp: +91-9876543210\n• In-app support ticket',
        category: 'Contact',
      ),
    ]);

    isLoading.value = false;
  }

  void loadSupportContacts() {
    supportContacts.assignAll([
      SupportContact(
        id: '1',
        type: 'phone',
        title: '24/7 Support Line',
        value: '1800-123-4567',
        icon: 'call',
        color: Colors.green,
      ),
      SupportContact(
        id: '2',
        type: 'email',
        title: 'Email Support',
        value: 'support@medicalb2b.com',
        icon: 'mail',
        color: Colors.blue,
      ),
      SupportContact(
        id: '3',
        type: 'whatsapp',
        title: 'WhatsApp Chat',
        value: '+91-9876543210',
        icon: 'chat',
        color: const Color(0xFF25D366),
      ),
      SupportContact(
        id: '4',
        type: 'chat',
        title: 'Live Chat',
        value: 'Available 9 AM - 9 PM',
        icon: 'forum',
        color: Colors.purple,
      ),
    ]);
  }

  void loadSupportTickets() {
    supportTickets.assignAll([
      SupportTicket(
        id: '1',
        title: 'Order not delivered',
        description: 'My order ORD-2024-001234 was supposed to be delivered yesterday but hasn\'t arrived yet.',
        category: 'Delivery & Shipping',
        status: 'Resolved',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        resolution: 'Delivery was delayed due to weather conditions. Order has been delivered now.',
      ),
      SupportTicket(
        id: '2',
        title: 'Wrong medicine received',
        description: 'Received Azithromycin 250mg instead of 500mg.',
        category: 'Product Quality',
        status: 'In Progress',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SupportTicket(
        id: '3',
        title: 'Payment failed but amount deducted',
        description: 'Payment failed but amount was deducted from my account.',
        category: 'Payment Problems',
        status: 'Resolved',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
        resolution: 'Refund initiated. Amount will be credited within 5-7 business days.',
      ),
    ]);
  }

  void toggleFAQ(String id) {
    final index = faqs.indexWhere((faq) => faq.id == id);
    if (index != -1) {
      faqs[index] = faqs[index].copyWith(isExpanded: !faqs[index].isExpanded);
    }
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
  }

  List<FAQ> getFilteredFAQs() {
    if (selectedCategory.value == 'All') {
      return faqs;
    }
    return faqs.where((faq) => faq.category == selectedCategory.value).toList();
  }

  List<String> getFAQCategories() {
    final categories = faqs.map((faq) => faq.category).toSet().toList();
    return ['All', ...categories];
  }

  void submitSupportTicket() {
    if (ticketTitleController.text.isEmpty ||
        ticketDescriptionController.text.isEmpty ||
        ticketCategoryController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all required fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final newTicket = SupportTicket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: ticketTitleController.text,
      description: ticketDescriptionController.text,
      category: ticketCategoryController.text,
      status: 'Submitted',
      createdAt: DateTime.now(),
    );

    supportTickets.insert(0, newTicket);

    // Clear form
    ticketTitleController.clear();
    ticketDescriptionController.clear();
    ticketCategoryController.clear();

    Get.back();

    Get.snackbar(
      'Ticket Submitted',
      'Your support ticket has been submitted successfully. Ticket ID: ${newTicket.id}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0B630B),
      colorText: Colors.white,
    );
  }

  void showCreateTicketDialog() {
    Get.bottomSheet(
      _buildTicketForm(),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildTicketForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
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
          const Text(
            'Create Support Ticket',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: ticketTitleController,
            decoration: const InputDecoration(
              labelText: 'Issue Title *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: ticketDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Description *',
              hintText: 'Describe your issue in detail...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: ticketCategoryController.text.isEmpty ? null : ticketCategoryController.text,
            decoration: const InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(),
            ),
            items: ticketCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              ticketCategoryController.text = value ?? '';
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: submitSupportTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B630B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Ticket'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void makeCall(String phoneNumber) {
    Get.snackbar(
      'Calling Support',
      'Calling $phoneNumber...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Implement actual call functionality
  }

  void sendEmail(String email) {
    Get.snackbar(
      'Email Support',
      'Opening email client for $email...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Implement email functionality
  }

  void openWhatsApp(String number) {
    Get.snackbar(
      'WhatsApp Support',
      'Opening WhatsApp for $number...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Implement WhatsApp functionality
  }

  void startLiveChat() {
    Get.snackbar(
      'Live Chat',
      'Connecting to support agent...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // Implement live chat functionality
  }
}