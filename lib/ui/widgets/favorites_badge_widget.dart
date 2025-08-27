import 'package:flutter/material.dart';

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
      onPressed: onTap,
      icon: Icon(
        hasFavorites ? Icons.favorite : Icons.favorite_border_outlined,
        color: hasFavorites ? Colors.red : null,
      ),
    );
  }
}