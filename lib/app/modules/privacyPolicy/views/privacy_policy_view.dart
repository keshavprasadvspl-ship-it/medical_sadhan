import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            // Privacy Policy Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: '1. Introduction',
                      content: 'Welcome to Medical B2B App ("we," "our," or "us"). We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
                    ),

                    _buildSection(
                      title: '2. Information We Collect',
                      content: '''
We collect personal information that you voluntarily provide to us when you register on the App, express an interest in obtaining information about us or our vendors_products and services, when you participate in activities on the App, or otherwise contact us.

The personal information we collect may include:
• Personal Identifiers: Name, email address, phone number
• Professional Information: Medical license number, qualification, specialization
• Business Information: Pharmacy/Hospital name, registration details, GST number
• Transaction Data: Purchase history, payment information
• Health Information: Prescriptions (with consent), medicine requirements
• Device Information: IP address, browser type, operating system
• Usage Data: App interaction, features used, time spent''',
                    ),

                    _buildSection(
                      title: '3. How We Use Your Information',
                      content: '''
We use personal information collected via our App for a variety of business purposes described below:
• Account Creation and Authentication
• Order Processing and Fulfillment
• Customer Support and Communication
• Personalization and Recommendations
• Legal Compliance and Regulatory Requirements
• Security and Fraud Prevention
• Business Operations and Analytics
• Marketing and Promotions (with consent)''',
                    ),

                    _buildSection(
                      title: '4. Information Sharing',
                      content: '''
We may share your information in the following situations:
• With Healthcare Providers: To fulfill prescriptions and medical orders
• With Delivery Partners: For order delivery and logistics
• With Payment Processors: For secure transaction processing
• With Government Authorities: As required by law or regulation
• With Business Partners: For integrated services (with consent)
• During Business Transfers: In case of merger or acquisition''',
                    ),

                    _buildSection(
                      title: '5. Data Security',
                      content: 'We have implemented appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, despite our safeguards and efforts to secure your information, no electronic transmission over the Internet or information storage technology can be guaranteed to be 100% secure.',
                    ),

                    _buildSection(
                      title: '6. Data Retention',
                      content: 'We will only keep your personal information for as long as it is necessary for the purposes set out in this privacy policy, unless a longer retention period is required or permitted by law (such as tax, accounting, or other legal requirements).',
                    ),

                    _buildSection(
                      title: '7. Your Privacy Rights',
                      content: '''
Depending on your location, you may have the following rights regarding your personal information:
• Right to Access: Request copies of your personal data
• Right to Rectification: Request correction of inaccurate data
• Right to Erasure: Request deletion of your personal data
• Right to Restrict Processing: Request restriction of data processing
• Right to Data Portability: Request transfer of your data
• Right to Object: Object to our processing of your data
• Right to Withdraw Consent: Withdraw consent at any time''',
                    ),

                    _buildSection(
                      title: '8. Cookies and Tracking',
                      content: 'We may use cookies and similar tracking technologies to access or store information. Most web browsers are set to accept cookies by default. You can choose to set your browser to remove or reject cookies, but note that this may affect certain features or services of our App.',
                    ),

                    _buildSection(
                      title: '9. Children\'s Privacy',
                      content: 'Our App is not intended for use by children under the age of 18. We do not knowingly collect personal information from children under 18. If we learn that we have collected personal information from a child under age 18, we will delete that information as quickly as possible.',
                    ),

                    _buildSection(
                      title: '10. Third-Party Services',
                      content: 'Our App may contain links to third-party websites and services that are not owned or controlled by us. We are not responsible for the privacy practices or content of these third-party services. We encourage you to review the privacy policies of any third-party services you visit.',
                    ),

                    _buildSection(
                      title: '11. Updates to This Policy',
                      content: 'We may update this privacy policy from time to time. The updated version will be indicated by an updated "Revised" date and the updated version will be effective as soon as it is accessible. We encourage you to review this privacy policy frequently to be informed of how we are protecting your information.',
                    ),

                    _buildSection(
                      title: '12. Contact Us',
                      content: '''
If you have questions or comments about this policy, you may contact our Data Protection Officer at:

Medical B2B App
Data Protection Officer
Email: privacy@medicalb2b.com
Phone: +91-XXX-XXXXXXX
Address: [Your Business Address]

Last Updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}''',
                    ),

                    const SizedBox(height: 40),

                    // Acceptance Checkbox
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF0B630B),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'By using our App, you acknowledge that you have read and understood this Privacy Policy.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () => Get.back(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0B630B),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 48),
                                    ),
                                    child: const Text('I Understand'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
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
            'Privacy Policy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF111261)),
            onPressed: () {
              Get.snackbar(
                'Download',
                'Privacy policy downloaded',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF111261)),
            onPressed: () {
              Get.snackbar(
                'Share',
                'Sharing privacy policy',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}