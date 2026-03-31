import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medical_b2b_app/app/modules/main/controllers/main_controller.dart';

class FloatingCartWidget extends StatefulWidget {
  const FloatingCartWidget({super.key});

  @override
  State<FloatingCartWidget> createState() => _FloatingCartWidgetState();
}

class _FloatingCartWidgetState extends State<FloatingCartWidget>
    with SingleTickerProviderStateMixin {
  Offset? _position;
  bool _manuallyClosed = false;
  int _previousCartCount = 0;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _initPosition(Size size) {
    if (_position == null) {
      const widgetWidth = 160.0;
      const widgetHeight = 50.0;
      const bottomNavHeight = 90.0;

      _position = Offset(
        (size.width / 2) - (widgetWidth / 2),
        size.height - bottomNavHeight - widgetHeight - 20,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mainController = Get.find<MainController>();

    _initPosition(size);

    return Obx(() {
      final count = mainController.cartCount.value;
      // isCartVisible observe karo — yahi trigger karega rebuild
      final isVisible = mainController.isCartVisible.value;

      print('🔄 FloatingCartWidget rebuild: count=$count, isVisible=$isVisible, manuallyClosed=$_manuallyClosed');

      // 🔥 Naya item aaya aur manually close tha — reopen karo
      if (count > _previousCartCount && _manuallyClosed) {
        _manuallyClosed = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animController.forward(from: 0.0);
        });
      }
      _previousCartCount = count;

      // 🔥 Hide conditions
      if (!isVisible) return const SizedBox.shrink();
      if (_manuallyClosed) return const SizedBox.shrink();

      // ✅ Positioned return karo — global Stack ka direct child hai
      return Positioned(
        left: _position!.dx,
        top: _position!.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _position = Offset(
                (_position!.dx + details.delta.dx).clamp(0.0, size.width - 170),
                (_position!.dy + details.delta.dy).clamp(0.0, size.height - 100),
              );
            });
          },
          onTap: () {
            debugPrint('🛒 Cart tapped!');
            mainController.goToCart();
          },
          child: ScaleTransition(
            scale: _scaleAnim,
            child: _cartUI(count, mainController),
          ),
        ),
      );
    });
  }

  Widget _cartUI(int count, MainController mainController) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 🛒 Main Cart Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF043734), Color(0xFF21827A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Go to Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          // 🔴 Count Badge
          if (count > 0)
            Positioned(
              top: -7,
              left: -7,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // ❌ Close Button
          Positioned(
            top: -7,
            right: -7,
            child: GestureDetector(
              onTap: () {
                setState(() => _manuallyClosed = true);
                mainController.hideFloatingCart();
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.close, size: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}