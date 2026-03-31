import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/data/providers/api_endpoints.dart';
import 'package:medical_b2b_app/app/global_widgets/controller/agency_controller.dart';
import 'package:medical_b2b_app/app/global_widgets/payment_method_dialog.dart';
import '../../../routes/app_pages.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/banner_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/auto_scroll_banner.dart';

class HomeView extends GetView<HomeController> {
 
DateTime? lastBackPressed;

@override
Widget build(BuildContext context) {
  Get.put(BannerController());

  return WillPopScope(
    onWillPop: () async {
      final now = DateTime.now();

      if (lastBackPressed == null ||
          now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
        lastBackPressed = now;
Get.snackbar(
  "Exit",
  "Double tap to exit",
  snackPosition: SnackPosition.BOTTOM,

  backgroundColor: Colors.white, // ✅ full white
  colorText: Colors.black,  

  margin: const EdgeInsets.all(12),
  borderRadius: 12,

  boxShadows: [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ],
);        return false;
      }

      return true;
    },

    child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE6F4F3),
              Color(0xFFF5FBFA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await controller.refreshData();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       

                        _buildQuickActions(),
                        const SizedBox(height: 24),

                        

                        _buildCompaniesList(),
                        const SizedBox(height: 28),
                        const AutoScrollBanner(),
                        const SizedBox(height: 24),
                        Obx(() => _buildCategoriesSection()),
                        const SizedBox(height: 28),

                        _buildFeaturedProducts(),
                        const SizedBox(height: 28),

                        _buildExploreProducts(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget _buildExploreProducts() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Explore More Products",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111261),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Obx(() {
        if (controller.isLoadingExplore.value &&
            controller.exploreProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.exploreProducts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("No products found"),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 6,
            childAspectRatio: 0.55,
          ),
          itemCount: controller.exploreProducts.length +
              (controller.hasMoreExploreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.exploreProducts.length) {
              Future.microtask(() {
                controller.loadExploreProducts(loadMore: true);
              });

              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final product = controller.exploreProducts[index];
            return _buildProductCard(product);
          },
        );
      }),
    ],
  );
}

Widget _buildProductCard(Map<String, dynamic> product) {
  String getProductImage() {
    if (product['images'] != null && product['images'] is List) {
      final imagesList = product['images'] as List;
      if (imagesList.isNotEmpty) return imagesList[0].toString();
    }
    return '';
  }

  // Price helper functions
  double getSellingPrice() {
    if (product['price'] != null) {
      if (product['price'] is String) {
        return double.tryParse(product['price']) ?? 0.0;
      }
      if (product['price'] is num) {
        return (product['price'] as num).toDouble();
      }
    }
    return 0.0;
  }

  double getMrpPrice() {
    if (product['mrp_price'] != null) {
      if (product['mrp_price'] is String) {
        return double.tryParse(product['mrp_price']) ?? 0.0;
      }
      if (product['mrp_price'] is num) {
        return (product['mrp_price'] as num).toDouble();
      }
    }
    // Fallback to mrp field if mrp_price doesn't exist
    if (product['mrp'] != null) {
      if (product['mrp'] is String) {
        return double.tryParse(product['mrp']) ?? 0.0;
      }
      if (product['mrp'] is num) {
        return (product['mrp'] as num).toDouble();
      }
    }
    return 0.0;
  }

  String getDiscountInfo() {
    int discountMin = 0;
    int discountMax = 0;
    int discountPercent = 0;

    // Get discount_min
    if (product['discount_min'] != null) {
      if (product['discount_min'] is int) {
        discountMin = product['discount_min'];
      } else if (product['discount_min'] is String) {
        discountMin = int.tryParse(product['discount_min']) ?? 0;
      }
    }

    // Get discount_max
    if (product['discount_max'] != null) {
      if (product['discount_max'] is int) {
        discountMax = product['discount_max'];
      } else if (product['discount_max'] is String) {
        discountMax = int.tryParse(product['discount_max']) ?? 0;
      }
    }

    // Get discount_percent
    if (product['discount_percent'] != null) {
      if (product['discount_percent'] is int) {
        discountPercent = product['discount_percent'];
      } else if (product['discount_percent'] is String) {
        discountPercent = int.tryParse(product['discount_percent']) ?? 0;
      }
    }

    // Return appropriate discount string
    if (discountMin > 0 && discountMax > 0) {
      return '$discountMin% - $discountMax%';
    } else if (discountPercent > 0) {
      return '$discountPercent% OFF';
    }
    
    return '';
  }

  bool hasDiscount() {
    final sellingPrice = getSellingPrice();
    final mrpPrice = getMrpPrice();
    return mrpPrice > sellingPrice;
  }

  String getCategoryName() {
    if (product['category'] != null && product['category']['name'] != null) {
      return product['category']['name'].toString();
    }
    if (product['sub_category'] != null &&
        product['sub_category']['name'] != null) {
      return product['sub_category']['name'].toString();
    }
    return 'General';
  }

  String getCompanyName() {
    if (product['company'] != null && product['company']['name'] != null) {
      return product['company']['name'].toString();
    }
    return '';
  }

  String getProductStrength() {
    if (product['power'] != null) {
      if (product['power'] is Map && product['power']['name'] != null) {
        return product['power']['name'].toString();
      }
      if (product['power'] is String) return product['power'];
    }
    if (product['unit'] != null) {
      if (product['unit'] is Map && product['unit']['name'] != null) {
        return product['unit']['name'].toString();
      }
      if (product['unit'] is String) return product['unit'];
    }
    return '';
  }

  String imagePath = getProductImage();
  String baseUrl = '${ApiEndpoints.imgUrl}/';

  String getFullImageUrl() {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    if (imagePath.startsWith('assets/')) return imagePath;
    if (imagePath.startsWith('/')) imagePath = imagePath.substring(1);
    return baseUrl + imagePath;
  }

  String fullImageUrl = getFullImageUrl();
  bool isNetworkImage = fullImageUrl.startsWith('http://') ||
      fullImageUrl.startsWith('https://');

  final bool isPrescription = product['is_prescription_required'] == 1;
  final String gstPercent = (product['gst_percentage'] ?? '12').toString();
  final String productName = product['name']?.toString() ?? 'Product Name';
  final String genericName = product['generic_name']?.toString() ?? '';
  final String hsnCode = product['hsn_code']?.toString() ?? '';
  final String strength = getProductStrength();
  final String category = getCategoryName();
  final String company = getCompanyName();
  final double sellingPrice = getSellingPrice();
  final double mrpPrice = getMrpPrice();
  final String discountInfo = getDiscountInfo();
  final bool showDiscount = hasDiscount() && discountInfo.isNotEmpty;

  return GestureDetector(
    onTap: () {
      final productId = product['id'];
      if (productId != null) {
        Get.toNamed('/product-details/${productId.toString()}');
      } else {
        Get.snackbar(
          'Error',
          'Invalid product ID',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2EA89E).withOpacity(0.2),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A5C57).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Image Section ───────────────────────────────────
          Stack(
            children: [
              // Image container
              Container(
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FAF9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Center(
                  child: isNetworkImage
                      ? Image.network(
                          fullImageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildMedPlaceholder(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Color(0xFF2EA89E),
                                ),
                              ),
                            );
                          },
                        )
                      : _buildMedPlaceholder(),
                ),
              ),

              // Rx badge
              if (isPrescription)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Rx',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              // GST badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A5C57),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'GST $gstPercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Discount badge REMOVED from image
            ],
          ),

          // Thin gradient divider
          Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A5C57), Color(0xFF2EA89E)],
              ),
            ),
          ),

          // ─── Details Section ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A3D3A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Generic Name
                if (genericName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    genericName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Strength
                if (strength.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.science_outlined,
                          size: 10, color: Colors.grey[500]),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          strength,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 8),

                // Category chip + Company
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A5C57).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF0A5C57),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (company.isNotEmpty)
                      Flexible(
                        child: Text(
                          company,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // ✅ Price Section with Discount
                if (sellingPrice > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${sellingPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0A5C57),
                            ),
                          ),
                          if (showDiscount) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                discountInfo,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (mrpPrice > 0 && mrpPrice > sellingPrice) ...[
                        const SizedBox(height: 2),
                        Text(
                          'MRP: ₹${mrpPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A5C57).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF2EA89E).withOpacity(0.2),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'Contact for price',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF0A5C57),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // HSN + View Details row
                Row(
                  children: [
                    if (hsnCode.isNotEmpty)
                      Text(
                        'HSN: $hsnCode',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[400],
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0A5C57), Color(0xFF2EA89E)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'View',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMedPlaceholder() {
  return Container(
    color: const Color(0xFFF0FAF9),
    child: const Icon(
      Icons.medication_rounded,
      size: 40,
      color: Color(0xFF2EA89E),
    ),
  );
} // Widget _buildBanner() {
  //   return Container(
  //     width: double.infinity,
  //     height: 180,
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [
  //           Color(0xFF043734),
  //           Color(0xFF0F8A0F),
  //         ],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.08),
  //           blurRadius: 12,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: Stack(
  //       children: [
  //         Positioned(
  //           right: -30,
  //           bottom: -30,
  //           child: Icon(
  //             Icons.medical_services,
  //             size: 180,
  //             color: Colors.white.withOpacity(0.08),
  //           ),
  //         ),
  //         Positioned(
  //           top: 16,
  //           right: 16,
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: const Row(
  //               children: [
  //                 Icon(
  //                   Icons.workspace_premium,
  //                   size: 16,
  //                   color: Color(0xFF043734),
  //                 ),
  //                 SizedBox(width: 6),
  //                 Text(
  //                   '1st Month Free',
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w600,
  //                     color: Color(0xFF043734),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 20),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const Text(
  //                 'Premium Membership',
  //                 style: TextStyle(
  //                   color: Colors.white70,
  //                   fontSize: 14,
  //                 ),
  //               ),
  //               const SizedBox(height: 6),
  //               const Text(
  //                 'Get Bulk Pricing\n& Priority Support',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   height: 1.3,
  //                 ),
  //               ),
  //               const SizedBox(height: 14),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   Get.toNamed(Routes.PRODUCTS);
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Colors.white,
  //                   foregroundColor: const Color(0xFF043734),
  //                   padding: const EdgeInsets.symmetric(
  //                       horizontal: 24, vertical: 12),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   'Start Free Trial',
  //                   style: TextStyle(
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
Widget _buildAppBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A5C57), // ✅ Thoda light — pehle 043734 tha
          Color(0xFF2EA89E), // ✅ Thoda light — pehle 21827A tha
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.12),
              ),
              child: Image.asset("assets/images/favicon.png"),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Medical Sadhan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'No Phone Calls – Direct Orders',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),

            // 🔔 Bell Icon
            GestureDetector(
              onTap: () {
                print("Notification clicked");
                // Get.toNamed(Routes.NOTIFICATIONS);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ✅ Light Search Box — theme se matched
        GestureDetector(
          onTap: () {
            print("Search area tapped");
            Get.toNamed(Routes.SEARCH);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white, // ✅ Pure white background
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Color(0xFF2EA89E), // ✅ Theme color ka icon
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Search Products...',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E), // ✅ Soft grey placeholder
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.mic,
                  color: Color(0xFF2EA89E), // ✅ Theme color ka icon
                  size: 22,
                ),

              ],
            ),
          ),
        ),
      ],
    ),
  );
}
// Replace _buildQuickActions with this updated version
  Widget _buildQuickActions() {
    return Obx(() {
      if (controller.isLoadingVendors.value && controller.vendors.isEmpty) {
        return _buildVendorsLoading();
      }

      if (controller.vendorsErrorMessage.isNotEmpty &&
          controller.vendors.isEmpty) {
        return _buildVendorsError();
      }

      if (controller.vendors.isEmpty) {
        return _buildEmptyVendors();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'All Agency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(Routes.VENDORS_LIST_VIEW);
                },
                child: Row(
                  children: [
                    const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF043734),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF043734),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190, // Slightly increased height for vendor cards
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.vendors.length > 10
                  ? 10
                  : controller.vendors.length, // Limit to 10
              itemBuilder: (context, index) {
                final vendor = controller.vendors[index];
                return _buildVendorCard(vendor);
              },
            ),
          ),
        ],
      );
    });
  }

Widget _buildVendorCard(Map<String, dynamic> vendor) {
  final vendorName = controller.getVendorName(vendor);
  final isActive = controller.isVendorActive(vendor);
  final logoUrl = controller.getVendorLogoUrl(vendor);
  final vendorCategory = controller.getVendorCategory(vendor);
  final isVerified = controller.isVendorVerified(vendor);

  print("vendor details");
  print(vendor);

  return GestureDetector(
  onTap: isActive
    ? () async {

        final global = Get.find<GlobalController>();

        // 🔥 STEP 1: agency select/store
        global.selectedAgencyId.value = vendor['user_details']['id'];

        print("Selected Agency ID: ${global.selectedAgencyId.value}");

        // STEP 2: Payment dialog
        final result = await Get.dialog<String>(
          PaymentMethodDialog(),
        );

        if (result == null) return;

        // STEP 3: Navigate (same as before)
        Get.toNamed(
          Routes.COMPANIES_LIST,
          arguments: {
            'vendorId': vendor['user_details']['id'],
            'vendorName': vendorName,
            'filterType': 'vendor',
          },
        );
      }
    : null,     child: Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? const Color(0xFF2EA89E).withOpacity(0.25)
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A5C57).withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top gradient strip
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A5C57), Color(0xFF2EA89E)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo — 90x90
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FAF9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2EA89E).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: logoUrl.isNotEmpty
                        ? Image.network(
                            logoUrl,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildLogoPlaceholder(),
                          )
                        : _buildLogoPlaceholder(),
                  ),
                ),

                const SizedBox(height: 8),

                // Vendor Name + Verified badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        vendorName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? const Color(0xFF0A5C57)
                              : Colors.grey[400],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color: Color(0xFF2EA89E),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                // Category chip
                if (vendorCategory.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A5C57).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vendorCategory,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A5C57),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 6),

                // Active status dot
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF2EA89E)
                            : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 9,
                        color: isActive
                            ? const Color(0xFF2EA89E)
                            : Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}// ✅ Logo placeholder

Widget _buildLogoPlaceholder() {
  return Container(
    color: const Color(0xFFF0FAF9),
    child: const Center(
      child: Icon(
        Icons.store_rounded,
        size: 48,
        color: Color(0xFF2EA89E),
      ),
    ),
  );
}// Loading state for vendors
  Widget _buildVendorsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'All Agency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 60,
                                height: 20,
                                color: Colors.grey[200],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 150,
                      height: 16,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.grey[200],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

// Error state for vendors
  Widget _buildVendorsError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'All Agency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              Text(
                controller.vendorsErrorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  controller.loadVendors();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF043734),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Empty state for vendors
  Widget _buildEmptyVendors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'All Agency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'No vendors available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompaniesList() {
    return Obx(() {
      if (controller.isLoadingCompanies.value && controller.companies.isEmpty) {
        return _buildCompaniesLoading();
      }

      if (controller.companiesErrorMessage.isNotEmpty &&
          controller.companies.isEmpty) {
        return _buildCompaniesError();
      }

      if (controller.companies.isEmpty) {
        return _buildEmptyCompanies();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Pharmaceutical Companies',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(Routes.COMPANIES_LIST);
                },
                child: Row(
                  children: [
                    const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF043734),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF043734),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120, // Increased height for larger images
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.companies.length,
              itemBuilder: (context, index) {
                final company = controller.companies[index];
                return _buildCompanyCard(company);
              },
            ),
          ),
        ],
      );
    });
  }
Widget _buildCompanyCard(Map<String, dynamic> company) {
  final companyName = company['name'] as String? ?? 'Unknown';
  final companyImage = company['logo'] as String?;
  final isActive = company['is_active'] as bool? ?? true;

  print("company");
  print(company);

  String getFullImageUrl() {
    if (companyImage == null || companyImage.isEmpty) return '';
    if (companyImage.startsWith('http://') ||
        companyImage.startsWith('https://')) {
      return companyImage;
    }
    String imagePath = companyImage;
    if (imagePath.startsWith('/')) imagePath = imagePath.substring(1);
    return '${ApiEndpoints.imgUrl}/$imagePath';
  }

  final String fullImageUrl = getFullImageUrl();

  return GestureDetector(
    onTap: isActive
        ? () {
            Get.toNamed(
              Routes.COMPANY_DIVISION,
              arguments: {
                'companyId': company['id'],
                'companyName': company['name'],
                'companyData': company,
                'filterType': 'company',
              },
            );
          }
        : null,
    child: Container(
      width: 100, // ✅ Chhota card
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.0), // ✅ Transparent body
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFF2EA89E).withOpacity(0.2) // ✅ Light weight border
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Company Image
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2EA89E).withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: fullImageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        width: 62,
                        height: 62,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildCompanyPlaceholder(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFFF0FAF9),
                            child: const Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Color(0xFF2EA89E),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : _buildCompanyPlaceholder(),
              ),
            ),

            const SizedBox(height: 7),

            // ✅ Company Name — small font
            Text(
              companyName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10, // ✅ Kam font size
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF0A5C57)
                    : Colors.grey[400],
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

// ✅ Placeholder
Widget _buildCompanyPlaceholder() {
  return Container(
    color: const Color(0xFFF0FAF9),
    child: const Center(
      child: Icon(
        Icons.business_rounded,
        size: 28,
        color: Color(0xFF2EA89E),
      ),
    ),
  );
}// Loading state for companies
  Widget _buildCompaniesLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Pharmaceutical Companies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 12,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

// Error state for companies
  Widget _buildCompaniesError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Pharmaceutical Companies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              Text(
                controller.companiesErrorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  controller.loadCompanies();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF043734),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Empty state for companies
  Widget _buildEmptyCompanies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Pharmaceutical Companies',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.business_center_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'No companies available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Updated _buildCategoriesSection method
// Updated _buildCategoriesSection method
  Widget _buildCategoriesSection() {
    if (controller.isLoading.value && controller.categories.isEmpty) {
      return _buildCategoriesLoading();
    }

    if (controller.errorMessage.isNotEmpty && controller.categories.isEmpty) {
      return _buildCategoriesError();
    }

    if (controller.categories.isEmpty) {
      return _buildEmptyCategories();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Product Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111261),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(Routes.CATEGORIES);
                },
                child: Row(
                  children: [
                    const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF043734),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF043734),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }

// Updated _buildCategoryCard method with new data structure
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final categoryName = category['name'] as String? ?? 'Unknown';
    final categoryImage = category['image'] as String?;
    final icon = category['icon'] as String? ?? '💊';
    final subCategories = category['subCategories'] as List?;
    final isActive = category['is_active'] as bool? ?? true;

    // Build full image URL
    String getFullImageUrl() {
      if (categoryImage == null || categoryImage.isEmpty) {
        return '';
      }

      // If it's already a full URL
      if (categoryImage.startsWith('http://') ||
          categoryImage.startsWith('https://')) {
        return categoryImage;
      }

      // Remove leading slash if present
      String imagePath = categoryImage;
      if (imagePath.startsWith('/')) {
        imagePath = imagePath.substring(1);
      }

      // Add base URL
      return '${ApiEndpoints.imgUrl}/$imagePath';
    }

    final String fullImageUrl = getFullImageUrl();

    return GestureDetector(
      onTap: isActive
          ? () {
              Get.toNamed(
                Routes.PRODUCTS,
                arguments: {
                  'category': category['name'], // Pass the category name
                  'categoryId': category['id'],
                  'filterType': 'category', // Add filter type identifier
                },
              );
            }
          : null,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.grey[200]! : Colors.grey[300]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Image or Icon
            if (fullImageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fullImageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading category image: $error');
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF043734),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // Category Name
            Text(
              categoryName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFF111261) : Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Subcategories Count
            if (subCategories != null && subCategories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${subCategories.length} ${subCategories.length == 1 ? 'subcategory' : 'subcategories'}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ),

            // Inactive Badge
            // if (!isActive)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 4),
            //     child: Container(
            //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            //       decoration: BoxDecoration(
            //         color: Colors.grey[300],
            //         borderRadius: BorderRadius.circular(4),
            //       ),
            //       child: const Text(
            //         'Inactive',
            //         style: TextStyle(
            //           fontSize: 8,
            //           color: Colors.grey,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

// Updated _buildCategoriesLoading method
  Widget _buildCategoriesLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 12,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Updated _buildCategoriesError method
  Widget _buildCategoriesError() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    controller.loadCategories();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF043734),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Updated _buildEmptyCategories method
  Widget _buildEmptyCategories() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111261),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  'No categories available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
Widget _buildFeaturedProducts() {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111261),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.offAllNamed('/main');

                Future.delayed(const Duration(milliseconds: 100), () {
                  final mainController = Get.find<MainController>();
                  mainController.currentIndex.value = 1;
                });
              },
              child: Row(
                children: [
                  const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF043734),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: Color(0xFF043734),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Obx(() {
        if (controller.isLoadingProducts.value &&
            controller.featuredProducts.isEmpty) {
          return _buildProductsLoading();
        }

        if (controller.productsErrorMessage.isNotEmpty &&
            controller.featuredProducts.isEmpty) {
          return _buildProductsError();
        }

        if (controller.featuredProducts.isEmpty) {
          return _buildEmptyProducts();
        }

        return SizedBox(
          height: 240, // Increased height to accommodate price section
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.featuredProducts.length,
            itemBuilder: (context, index) {
              final product = controller.featuredProducts[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    Routes.PRODUCT_DETAILS,
                    parameters: {
                      'id': product['id'].toString(),
                    },
                  );
                },
                child: _buildFeaturedProductCard(product),
              );
            },
          ),
        );
      }),
    ],
  );
}

Widget _buildFeaturedProductCard(Map<String, dynamic> product) {
  // Helper functions
  String getProductImage() {
    if (product['images'] != null && product['images'] is List) {
      final imagesList = product['images'] as List;
      if (imagesList.isNotEmpty) return imagesList[0].toString();
    }
    return '';
  }

  String getCategoryName() {
    if (product['category'] != null && product['category']['name'] != null) {
      return product['category']['name'].toString();
    }
    if (product['sub_category'] != null &&
        product['sub_category']['name'] != null) {
      return product['sub_category']['name'].toString();
    }
    return 'General';
  }

  String getCompanyName() {
    if (product['company'] != null && product['company']['name'] != null) {
      return product['company']['name'].toString();
    }
    return '';
  }

  String getProductStrength() {
    if (product['power'] != null) {
      if (product['power'] is Map && product['power']['name'] != null) {
        return product['power']['name'].toString();
      }
      if (product['power'] is String) return product['power'];
    }
    if (product['unit'] != null) {
      if (product['unit'] is Map && product['unit']['name'] != null) {
        return product['unit']['name'].toString();
      }
      if (product['unit'] is String) return product['unit'];
    }
    return '';
  }

  // New helper functions for pricing
  double getSellingPrice() {
    if (product['price'] != null) {
      if (product['price'] is String) {
        return double.tryParse(product['price']) ?? 0.0;
      }
      if (product['price'] is num) {
        return (product['price'] as num).toDouble();
      }
    }
    return 0.0;
  }

  double getMrpPrice() {
    if (product['mrp_price'] != null) {
      if (product['mrp_price'] is String) {
        return double.tryParse(product['mrp_price']) ?? 0.0;
      }
      if (product['mrp_price'] is num) {
        return (product['mrp_price'] as num).toDouble();
      }
    }
    // Fallback to mrp field if mrp_price doesn't exist
    if (product['mrp'] != null) {
      if (product['mrp'] is String) {
        return double.tryParse(product['mrp']) ?? 0.0;
      }
      if (product['mrp'] is num) {
        return (product['mrp'] as num).toDouble();
      }
    }
    return 0.0;
  }

  String getDiscountInfo() {
    int discountMin = 0;
    int discountMax = 0;
    int discountPercent = 0;

    // Get discount_min
    if (product['discount_min'] != null) {
      if (product['discount_min'] is int) {
        discountMin = product['discount_min'];
      } else if (product['discount_min'] is String) {
        discountMin = int.tryParse(product['discount_min']) ?? 0;
      }
    }

    // Get discount_max
    if (product['discount_max'] != null) {
      if (product['discount_max'] is int) {
        discountMax = product['discount_max'];
      } else if (product['discount_max'] is String) {
        discountMax = int.tryParse(product['discount_max']) ?? 0;
      }
    }

    // Get discount_percent
    if (product['discount_percent'] != null) {
      if (product['discount_percent'] is int) {
        discountPercent = product['discount_percent'];
      } else if (product['discount_percent'] is String) {
        discountPercent = int.tryParse(product['discount_percent']) ?? 0;
      }
    }

    // Return appropriate discount string
    if (discountMin > 0 && discountMax > 0) {
      return '$discountMin% - $discountMax%';
    } else if (discountPercent > 0) {
      return '$discountPercent% OFF';
    }
    
    return '';
  }

  bool hasDiscount() {
    final sellingPrice = getSellingPrice();
    final mrpPrice = getMrpPrice();
    return mrpPrice > sellingPrice;
  }

  // Get values
  String imagePath = getProductImage();
  String baseUrl = '${ApiEndpoints.imgUrl}/';
  final double sellingPrice = getSellingPrice();
  final double mrpPrice = getMrpPrice();
  final String discountInfo = getDiscountInfo();
  final bool showDiscount = hasDiscount() && discountInfo.isNotEmpty;

  String getFullImageUrl() {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    if (imagePath.startsWith('assets/')) return imagePath;
    if (imagePath.startsWith('/')) imagePath = imagePath.substring(1);
    return baseUrl + imagePath;
  }

  String fullImageUrl = getFullImageUrl();
  bool isNetworkImage =
      fullImageUrl.startsWith('http://') || fullImageUrl.startsWith('https://');

  final bool isPrescription = product['is_prescription_required'] == 1;
  final String gstPercent = (product['gst_percentage'] ?? '12').toString();
  final String productName = product['name']?.toString() ?? 'Product Name';
  final String genericName = product['generic_name']?.toString() ?? '';
  final String strength = getProductStrength();
  final String company = getCompanyName();

  return GestureDetector(
    onTap: () {
      final productId = product['id'];
      if (productId != null) {
        Get.toNamed('/product-details/${productId.toString()}');
      } else {
        Get.snackbar(
          'Error',
          'Invalid product ID',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    },
    child: Container(
      margin: const EdgeInsets.only(right: 14),
      width: 300, // Slightly increased width for better price display
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A5C57), Color(0xFF2EA89E)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A5C57).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with image and basic info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Image
                      SizedBox(
                        width: 90,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: isNetworkImage
                                  ? Image.network(
                                      fullImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildFeaturedPlaceholder(),
                                      loadingBuilder:
                                          (context, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : _buildFeaturedPlaceholder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Right: Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Featured badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.star_rounded,
                                      size: 10, color: Colors.amber),
                                  SizedBox(width: 3),
                                  Text(
                                    'Featured',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Product Name
                            Text(
                              productName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Generic Name
                            if (genericName.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                genericName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.75),
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],

                            // Strength
                            if (strength.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.science_outlined,
                                      size: 10,
                                      color: Colors.white.withOpacity(0.7)),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      strength,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Company
                            if (company.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.business_rounded,
                                      size: 10,
                                      color: Colors.white.withOpacity(0.7)),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      company,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price Section
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selling Price
                            Text(
                              '₹${sellingPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            // MRP with strikethrough if discounted
                            if (showDiscount) ...[
                              const SizedBox(height: 2),
                              Text(
                                '₹${mrpPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.6),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Discount Badge
                        if (showDiscount)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              discountInfo,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bottom chips row
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // GST chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'GST $gstPercent%',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Rx chip
                      if (isPrescription)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[700],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Rx',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                      // View button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'View →',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF0A5C57),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
  );
}

// Placeholder widget for featured products
Widget _buildFeaturedPlaceholder() {
  return Container(
    color: Colors.white.withOpacity(0.1),
    child: const Center(
      child: Icon(
        Icons.medication_rounded,
        size: 35,
        color: Colors.white,
      ),
    ),
  );
}

// Loading widget
Widget _buildProductsLoading() {
  return const Center(
    child: CircularProgressIndicator(
      color: Color(0xFF043734),
    ),
  );
}

// Error widget
Widget _buildProductsError() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          'Failed to load products',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            controller.loadFeaturedProducts();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF043734),
          ),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

// Empty products widget
Widget _buildEmptyProducts() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          'No featured products available',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}



}
