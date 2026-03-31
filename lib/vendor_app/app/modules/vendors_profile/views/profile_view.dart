import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../app/routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class VendorsProfileView extends GetView<VendorsProfileController> {
  const VendorsProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!controller.isEditing.value)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: controller.toggleEdit,
                  ),

                if (controller.isEditing.value) ...[
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: controller.cancelEdit,
                  ),

                  IconButton(
                    icon: controller.isSaving.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.check, color: Colors.green),
                    onPressed: controller.isSaving.value
                        ? null
                        : controller.toggleEdit,
                  ),
                ],
              ],
            );
          }),

        IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Obx(() => controller.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with Cover
            _buildProfileHeader(),

            // Profile Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verification Status
                  if (!controller.isVerified.value)
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your account is pending verification. Please complete your profile for verification.',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Company Information
                  _buildSectionTitle('Company Information'),
                  SizedBox(height: 12),
                  _buildInfoCard(
                    children: [
                      _buildEditableField(
                        label: 'Business Name',
                        value: controller.businessName.value,
                        textController: controller.businessNameController,
                        icon: Icons.business,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Business Type',
                        value: controller.businessType.value,
                        textController: controller.businessTypeController,
                        icon: Icons.category,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Contact Person',
                        value: controller.contactPerson.value,
                        textController: controller.contactPersonController,
                        icon: Icons.person,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Designation',
                        value: controller.designation.value,
                        textController: controller.designationController,
                        icon: Icons.badge,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Contact Information
                  _buildSectionTitle('Contact Information'),
                  SizedBox(height: 12),
                  _buildInfoCard(
                    children: [
                      _buildEditableField(
                        label: 'Name',
                        value: controller.name.value,
                        textController: controller.nameController,
                        icon: Icons.person_outline,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Email',
                        value: controller.email.value,
                        textController: controller.emailController,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Phone',
                        value: controller.phone.value,
                        textController: controller.phoneController,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Business Details
                  _buildSectionTitle('Business Details'),
                  SizedBox(height: 12),
                  _buildInfoCard(
                    children: [
                      _buildEditableField(
                        label: 'GST Number',
                        value: controller.gstNumber.value,
                        textController: controller.gstNumberController,
                        icon: Icons.numbers,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Registration Number',
                        value: controller.companyRegistrationNumber.value,
                        textController: controller.companyRegistrationNumberController,
                        icon: Icons.assignment_ind,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Drug License Number',
                        value: controller.drugLicenseNumber.value,
                        textController: controller.drugLicenseNumberController,
                        icon: Icons.description,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Year of Establishment',
                        value: controller.yearOfEstablishment.value,
                        textController: controller.yearOfEstablishmentController,
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Average Monthly Sales (₹)',
                        value: controller.averageMonthlySales.value.toStringAsFixed(0),
                        textController: controller.averageMonthlySalesController,
                        icon: Icons.trending_up,
                        keyboardType: TextInputType.number,
                      ),
                      _buildDivider(),
                      _buildEditableField(
                        label: 'Vendor Category',
                        value: controller.vendorCategory.value,
                        textController: controller.vendorCategoryController,
                        icon: Icons.label,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  // Notes Section
                  if (controller.notes.value.isNotEmpty || controller.isEditing.value)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Additional Notes'),
                        SizedBox(height: 12),
                        _buildInfoCard(
                          children: [
                            _buildEditableField(
                              label: 'Notes',
                              value: controller.notes.value,
                              textController: controller.notesController,
                              icon: Icons.note,
                              maxLines: 3,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),

                  // Contact Actions
                  _buildSectionTitle('Quick Actions'),
                  SizedBox(height: 12),
                  _buildActionsCard(),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Profile is index 3
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offNamed(Routes.VENDERS_DASHBOARD);
              break;
            case 1:
              Get.offNamed(Routes.VENDERS_ORDERS);
              break;
            case 2:
              Get.offNamed(Routes.VENDORS_PORDUCTS);
              break;
            case 3:
            // Already on profile
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: controller.logoUrl.value.isNotEmpty
                        ? NetworkImage(controller.logoUrl.value)
                        : null,
                    child: controller.logoUrl.value.isEmpty
                        ? Text(
                      (controller.businessName.value.isNotEmpty
                          ? controller.businessName.value[0]
                          : 'M')
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    )
                        : null,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(Get.context!).size.width - 140,
                      child: Text(
                        controller.businessName.value.isNotEmpty
                            ? controller.businessName.value
                            : 'Business Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              controller.vendorRating.value.toStringAsFixed(1),
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: controller.isVerified.value ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller.isVerified.value ? 'Verified' : 'Pending',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${controller.successfulOrders.value} successful orders',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blue.shade700),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Not provided',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required TextEditingController textController,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Obx(() => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blue.shade700),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2),
              controller.isEditing.value
                  ? TextFormField(
                controller: textController,
                maxLines: maxLines,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )
                  : Text(
                value.isNotEmpty ? value : 'Not provided',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.call, color: Colors.green.shade700),
            ),
            title: Text('Call Support'),
            subtitle: Text('+91 1800 123 4567'),
            trailing: Icon(Icons.phone_in_talk, color: Colors.green),
            onTap: () async {
              final Uri telUri = Uri(scheme: 'tel', path: '+9118001234567');
              if (await canLaunchUrl(telUri)) {
                await launchUrl(telUri);
              }
            },
          ),
          Divider(height: 0, indent: 70),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.email, color: Colors.blue.shade700),
            ),
            title: Text('Email Support'),
            subtitle: Text('support@medisupply.com'),
            trailing: Icon(Icons.send, color: Colors.blue),
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'support@medisupply.com',
                query: 'subject=Support Request',
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              }
            },
          ),
          Divider(height: 0, indent: 70),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.share, color: Colors.purple.shade700),
            ),
            title: Text('Share Profile'),
            subtitle: Text('Invite others to connect'),
            trailing: Icon(Icons.share, color: Colors.purple),
            onTap: () {
              Get.snackbar(
                'Share',
                'Share functionality will be implemented soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }
}