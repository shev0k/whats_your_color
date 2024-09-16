// top_navigation_bar.dart
import 'package:flutter/material.dart';

class TopNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onInteractionPressed;
  final VoidCallback onStatisticsPressed;
  final bool showBackButton;

  const TopNavigationBar({
    super.key,
    required this.onBackPressed,
    required this.onInteractionPressed,
    required this.onStatisticsPressed,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // AppBar transparent
      elevation: 0, // remove shadow
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: onBackPressed,
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.nfc, color: Colors.white),
          onPressed: onInteractionPressed,
          tooltip: 'Interaction',
        ),
        IconButton(
          icon: const Icon(Icons.bar_chart, color: Colors.white),
          onPressed: onStatisticsPressed,
          tooltip: 'Statistics',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
