// lib/app/modules/home/widgets/auto_scroll_banner.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/banner_controller.dart';
import '../../../data/models/banner_model.dart';

class AutoScrollBanner extends GetView<BannerController> {
  const AutoScrollBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.banners.isEmpty) {
        return _buildShimmerLoading();
      }

      if (controller.banners.isEmpty) {
        return const SizedBox.shrink();
      }

      return _buildBannerCarousel();
    });
  }

  // ── Carousel ──────────────────────────────────────────────────────────────
  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          Listener(
            onPointerDown: (_) => controller.pauseAutoScroll(),
            onPointerUp: (_) => controller.resumeAutoScroll(),
            onPointerCancel: (_) => controller.resumeAutoScroll(),
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.banners.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildBannerItem(controller.banners[index]),
                );
              },
            ),
          ),

          // Dot indicators
          if (controller.banners.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.banners.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Banner card ───────────────────────────────────────────────────────────
  Widget _buildBannerItem(BannerModel banner) {
    final Color bgColor =
        banner.backgroundParsedColor ?? const Color(0xFF043734);

    return GestureDetector(
      onTap: () => controller.onBannerTap(banner),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Full banner image (covers entire card) ──────────────────
              if (banner.fullImageUrl.isNotEmpty)
                Image.network(
                  banner.fullImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallbackBg(bgColor),
                )
              else
                _buildFallbackBg(bgColor),

              // ── Overlay content (only shown when API sends text/button) ──
              _buildOverlayContent(banner),
            ],
          ),
        ),
      ),
    );
  }

  // ── Overlay: renders ONLY if API returns non-empty text fields ────────────
  Widget _buildOverlayContent(BannerModel banner) {
    final bool hasSubtitle =
        banner.subtitle != null && banner.subtitle!.isNotEmpty;
    final bool hasTitle = banner.title.isNotEmpty;
    final bool hasDescription =
        banner.description != null && banner.description!.isNotEmpty;
    final bool hasButton =
        banner.buttonText != null && banner.buttonText!.isNotEmpty;
    final bool hasPremiumBadge =
        banner.title.toLowerCase().contains('premium') ||
        banner.subtitle?.toLowerCase().contains('premium') == true;

    // If no text content at all, return empty — image fills the card
    if (!hasTitle && !hasSubtitle && !hasDescription && !hasButton) {
      return const SizedBox.shrink();
    }

    final Color textColor = banner.textParsedColor ?? Colors.white;
    final Color bgColor =
        banner.backgroundParsedColor ?? const Color(0xFF043734);

    return Stack(
      children: [
        // Semi-transparent gradient so text is readable over image
        if (banner.fullImageUrl.isNotEmpty)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.45),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

        // Premium badge
        if (hasPremiumBadge)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, size: 16, color: bgColor),
                  const SizedBox(width: 6),
                  Text(
                    'Premium',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: bgColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Text + button column
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasSubtitle)
                Text(
                  banner.subtitle!,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              if (hasSubtitle) const SizedBox(height: 6),
              if (hasTitle)
                Text(
                  banner.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (hasDescription) ...[
                const SizedBox(height: 4),
                Text(
                  banner.description!,
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (hasButton) ...[
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => controller.onBannerTap(banner),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: bgColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    banner.buttonText!,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Fallback when image fails or imageUrl is empty ────────────────────────
  Widget _buildFallbackBg(Color bgColor) {
    return Container(color: bgColor);
  }

  // ── Dot indicator ─────────────────────────────────────────────────────────
  Widget _buildPageIndicator(int index) {
    return Obx(() {
      final bool isActive = controller.currentPage.value == index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: isActive ? 20 : 8,
        height: 8,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color:
              isActive ? Colors.white : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    });
  }

  // ── Loading shimmer ───────────────────────────────────────────────────────
  Widget _buildShimmerLoading() {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF043734),
        ),
      ),
    );
  }
}