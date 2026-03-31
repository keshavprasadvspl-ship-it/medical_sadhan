// product_details_view.dart - FIXED VERSION WITH DISCOUNT MIN/MAX
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/product_details_model.dart';
import '../../../data/models/related_product_model.dart';
import '../../../data/providers/api_endpoints.dart';
import '../../../global_widgets/add_to_cart_popup.dart';
import '../../main/controllers/main_controller.dart';
import '../controllers/product_details_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        if (controller.isLoading.value && controller.product.value == null) {
          return _buildLoading();
        }

        if (controller.errorMessage.isNotEmpty && controller.product.value == null) {
          return _buildErrorState();
        }

        final product = controller.product.value;
        if (product == null) {
          return _buildEmptyState();
        }

        return _buildProductDetail(product);
      }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProductDetail(ProductDetail product) {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (controller.product.value != null) {
                await controller.refresh();
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImages(product),
                  _buildProductInfo(product),
                  if (product.description.isNotEmpty) _buildDescriptionSection(product),
                  _buildIngredientsSection(product),
                  _buildSpecificationsSection(product),
                  _buildRelatedProductsSection(),
                  Obx(() => controller.reviews.isNotEmpty
                      ? _buildReviewsSection()
                      : const SizedBox()),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 50, bottom: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF043734),
            Color(0xFF21827A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Product Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // Helper method to get discount badge text directly from API values
  String _getDiscountBadgeText(ProductDetail product) {
    final min = product.discount_min;
    final max = product.discount_max;

    if (min != null && max != null && min != max) {
      return '${min.round()}% – ${max.round()}% off';
    } else if (min != null && min > 0) {
      return '${min.round()}% off';
    } else if (max != null && max > 0) {
      return '${max.round()}% off';
    } else if (product.discountPercent > 0) {
      return '${product.discountPercent.round()}% off';
    }
    return '';
  }

  // Helper method to check if discount exists
  bool _hasDiscount(ProductDetail product) {
    return (product.discount_min != null && product.discount_min! > 0) || 
           (product.discount_max != null && product.discount_max! > 0) ||
           product.discountPercent > 0;
  }

  // Product Images Section
  Widget _buildProductImages(ProductDetail product) {
    final hasImages = product.images.isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Obx(() {
            final index = controller.selectedImageIndex.value;

            return Container(
              height: 250,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Center(
                    child: _buildMainImage(product, index),
                  ),
                  
                  // Discount Badge - Direct API values
                  if (_hasDiscount(product))
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                            Color(0xFF4A0000),  // very dark red
                            Color(0xFFE53935),  // bright red  // vibrant orange
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
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
                          _getDiscountBadgeText(product),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (product.isPrescriptionRequired)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Rx',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          if (hasImages && product.images.length > 1)
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: product.images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      controller.changeImage(index);
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.selectedImageIndex.value == index
                              ? const Color(0xFF043734)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildThumbnailImage(product.images[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainImage(ProductDetail product, int index) {
    if (product.images.isEmpty) {
      return const Icon(
        Icons.medical_services,
        size: 100,
        color: Color(0xFF111261),
      );
    }

    final imagePath = product.images[index];
    
    if (imagePath.isEmpty) {
      return const Icon(
        Icons.broken_image,
        size: 100,
        color: Colors.grey,
      );
    }

    final String baseUrl = '${ApiEndpoints.imgUrl}/';
    String fullImageUrl;
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      fullImageUrl = imagePath;
    } else if (imagePath.startsWith('/')) {
      fullImageUrl = baseUrl + imagePath.substring(1);
    } else {
      fullImageUrl = baseUrl + imagePath;
    }

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF043734),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThumbnailImage(String imageUrl) {
    return _buildImageWidget(imageUrl);
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.isEmpty) {
      return const Center(
        child: Icon(
          Icons.medical_services,
          size: 30,
          color: Color(0xFF111261),
        ),
      );
    }

    final String baseUrl = '${ApiEndpoints.imgUrl}/';
    String fullImageUrl;
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      fullImageUrl = imagePath;
    } else if (imagePath.startsWith('/')) {
      fullImageUrl = baseUrl + imagePath.substring(1);
    } else {
      fullImageUrl = baseUrl + imagePath;
    }

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF043734),
          strokeWidth: 2,
        ),
      ),
      errorWidget: (context, url, error) {
        return const Center(
          child: Icon(
            Icons.broken_image,
            size: 30,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  // Product Info Section
  Widget _buildProductInfo(ProductDetail product) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111261).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.subCategory?.name != null || product.category?.name != null)
            Text(
              product.subCategory?.name ?? product.category?.name ?? 'Medicine',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 8),

          Text(
            product.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 4),

          if (product.genericName.isNotEmpty) ...[
            _buildInfoRow('Composition:', product.genericName),
            const SizedBox(height: 4),
          ],

          if (product.company.name.isNotEmpty)
            _buildInfoRow('Company:', product.company.name),

          if (product.agency?.isNotEmpty == true)
            _buildInfoRow('Agency:', product.agency!),

          const Divider(height: 24, thickness: 1),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${product.originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF043734),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (product.mrp != null && product.mrp! > 0)
                      Row(
                        children: [
                          const Text(
                            'MRP: ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '₹${product.mrp!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GST:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.gstPercentage > 0
                          ? '${product.gstPercentage}%'
                          : 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111261),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unit:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.unit?.name.isNotEmpty == true
                          ? product.unit!.name
                          : 'N/A',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111261),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 18,
                          color: Color(0xFF043734),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111261),
                          ),
                        ),
                        Text(
                          ' (${product.ratingCount})',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_hasDiscount(product)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF043734).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
                        ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111261),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Description Section
  Widget _buildDescriptionSection(ProductDetail product) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111261).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.description.isNotEmpty
                ? product.description
                : 'No description available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Ingredients Section
  Widget _buildIngredientsSection(ProductDetail product) {
    final ingredients = controller.getIngredients();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111261).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredients / Composition',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 12),
          if (ingredients.isNotEmpty)
            ...ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF043734),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (product.saltComposition?.name.isNotEmpty == true)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF043734),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    product.saltComposition!.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              'No ingredients information available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  // Specifications Section
  Widget _buildSpecificationsSection(ProductDetail product) {
    final specs = <Map<String, String>>[];

    if (product.power?.name.isNotEmpty == true) {
      specs.add({'Power': product.power!.name!});
    }

    if (product.hsnCode.isNotEmpty) {
      specs.add({'HSN Code': product.hsnCode});
    }

    if (product.gstPercentage > 0) {
      specs.add({'GST': '${product.gstPercentage}%'});
    }

    if (product.unit?.name.isNotEmpty == true) {
      specs.add({'Unit': product.unit!.name});
    }

    if (specs.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111261).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111261),
            ),
          ),
          const SizedBox(height: 12),
          ...specs.map(
            (spec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      spec.keys.first,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    spec.values.first,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF111261),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Related Products Section
  Widget _buildRelatedProductsSection() {
    return Obx(() {
      if (controller.isLoadingRelated.value) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF111261).withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF043734),
                  strokeWidth: 2,
                ),
                SizedBox(height: 8),
                Text(
                  'Loading related products...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.relatedProducts.isEmpty) {
        return const SizedBox();
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Related Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111261),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.relatedProducts.length,
                itemBuilder: (context, index) {
                  final related = controller.relatedProducts[index];
                  return _buildRelatedProductCard(related);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRelatedProductCard(RelatedProduct related) {
    return GestureDetector(
      onTap: () {
        Get.offNamed('/product-details/${related.id}');
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: _buildRelatedProductImage(related.imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    related.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111261),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    related.company.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    related.formattedPrice,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF043734),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (related.isPrescriptionRequired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Rx',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const Icon(
        Icons.medical_services,
        size: 40,
        color: Color(0xFF111261),
      );
    }

    final String baseUrl = '${ApiEndpoints.imgUrl}/';
    String fullImageUrl;
    
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      fullImageUrl = imageUrl;
    } else if (imageUrl.startsWith('/')) {
      fullImageUrl = baseUrl + imageUrl.substring(1);
    } else {
      fullImageUrl = baseUrl + imageUrl;
    }

    return CachedNetworkImage(
      imageUrl: fullImageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF043734),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => const Icon(
        Icons.broken_image,
        size: 30,
        color: Colors.grey,
      ),
    );
  }

  // Reviews Section
  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF111261).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111261),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFF043734),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (controller.reviews.isEmpty)
            const Center(
              child: Text(
                'No reviews yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...controller.reviews.map(
              (review) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF111261),
                          radius: 20,
                          child: Text(
                            (review['avatar'] as String? ?? 'U')[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['name'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111261),
                                ),
                              ),
                              Text(
                                review['date'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFF043734),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${review['rating']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111261),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review['comment'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Bottom Bar
  Widget _buildBottomBar() {
    return Obx(() {
      final product = controller.product.value;
      if (product == null) return const SizedBox();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF111261).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.dialog(
                      AddToCartPopup(product: product),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF043734),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Loading State
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF043734),
          ),
          SizedBox(height: 16),
          Text(
            'Loading product details...',
            style: TextStyle(
              color: Color(0xFF111261),
            ),
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.orange[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111261),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  )),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final productId = Get.parameters['id'];
                      if (productId != null) {
                        controller.loadProductDetails(int.parse(productId));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF043734),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No product found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111261),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The product you\'re looking for doesn\'t exist or has been removed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF043734),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}