// lib/app/modules/home/controllers/banner_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/banner_model.dart';
// TODO: import your banner repository/service here
// import '../../../data/repositories/banner_repository.dart';

class BannerController extends GetxController {
  // ── Observables ──────────────────────────────────────────────────────────
  final RxList<BannerModel> banners = <BannerModel>[].obs;
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = false.obs;

  // ── Page controller ───────────────────────────────────────────────────────
  late final PageController pageController;

  // ── Auto-scroll ───────────────────────────────────────────────────────────
  Timer? _autoScrollTimer;
  static const Duration _scrollInterval = Duration(seconds: 3);
  static const Duration _scrollDuration = Duration(milliseconds: 400);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    fetchBanners();
  }

  @override
  void onClose() {
    _stopAutoScroll();
    pageController.dispose();
    super.onClose();
  }

  // ── Data fetching ─────────────────────────────────────────────────────────
  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;

      // TODO: replace with your actual API call, e.g.:
      // final result = await _bannerRepository.getBanners();
      // banners.value = result.where((b) => b.isActive).toList()
      //   ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      // ── Placeholder — remove when wiring real API ──
      await Future.delayed(const Duration(seconds: 1));
      banners.value = _mockBanners();
      // ──────────────────────────────────────────────

    } catch (e) {
      debugPrint('BannerController.fetchBanners error: $e');
    } finally {
      isLoading.value = false;
      _startAutoScroll();
    }
  }

  // ── Page callbacks ────────────────────────────────────────────────────────
  void onPageChanged(int index) {
    currentPage.value = index;
    _startAutoScroll(); // reset 3-s window on every page change
  }

  void onBannerTap(BannerModel banner) {
    if (banner.buttonAction == null || banner.buttonAction!.isEmpty) return;
    // TODO: handle navigation, e.g. Get.toNamed(banner.buttonAction!)
    debugPrint('Banner tapped: id=${banner.id} → ${banner.buttonAction}');
  }

  // ── Auto-scroll ───────────────────────────────────────────────────────────
  void _startAutoScroll() {
    _stopAutoScroll();
    if (banners.length <= 1) return;

    _autoScrollTimer = Timer.periodic(_scrollInterval, (_) {
      if (!pageController.hasClients) return;
      final int next = (currentPage.value + 1) % banners.length;
      pageController.animateToPage(
        next,
        duration: _scrollDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void pauseAutoScroll() => _stopAutoScroll();
  void resumeAutoScroll() => _startAutoScroll();

  // ── Mock data (delete after wiring real API) ──────────────────────────────
  // Only imageUrl is kept — all text fields are null/empty
  // The widget will show only the image when text fields are empty
  List<BannerModel> _mockBanners() {
    return [
      BannerModel(
        id: 1,
        title: '',           // coming from API
        subtitle: null,      // coming from API
        description: null,   // coming from API
        imageUrl: 'https://placehold.co/800x300/043734/png', // replace with real URL
        buttonText: null,    // coming from API
        buttonAction: null,  // coming from API
        backgroundColor: null,
        textColor: null,
        displayOrder: 1,
        isActive: true,
      ),
      BannerModel(
        id: 2,
        title: '',           // coming from API
        subtitle: null,      // coming from API
        description: null,   // coming from API
        imageUrl: 'https://placehold.co/800x300/1a3a5c/png', // replace with real URL
        buttonText: null,    // coming from API
        buttonAction: null,  // coming from API
        backgroundColor: null,
        textColor: null,
        displayOrder: 2,
        isActive: true,
      ),
      BannerModel(
        id: 3,
        title: '',           // coming from API
        subtitle: null,      // coming from API
        description: null,   // coming from API
        imageUrl: 'https://placehold.co/800x300/4a1a5c/png', // replace with real URL
        buttonText: null,    // coming from API
        buttonAction: null,  // coming from API
        backgroundColor: null,
        textColor: null,
        displayOrder: 3,
        isActive: true,
      ),
    ];
  }
}