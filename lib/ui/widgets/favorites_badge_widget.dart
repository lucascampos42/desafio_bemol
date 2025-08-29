import 'package:flutter/material.dart';
import '../../core/utils/animations.dart';

class FavoritesBadgeWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasFavorites;

  const FavoritesBadgeWidget({
    super.key,
    required this.onTap,
    required this.hasFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('favorites_navigation_button'),
      onPressed: onTap,
      icon: AppAnimations.favoriteHeart(
        isFavorite: hasFavorites,
        onTap: onTap,
        size: 24,
      ),
    );
  }
}