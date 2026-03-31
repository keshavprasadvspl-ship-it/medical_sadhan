// lib/app/core/widgets/offline_wrapper.dart
import 'package:flutter/material.dart';
import 'offline_screen.dart';

class OfflineWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRetry;

  const OfflineWrapper({
    Key? key,
    required this.child,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OfflineScreen(
      child: child,
      onRetry: onRetry,
    );
  }
}