import 'package:desafio_bemol/core/theme/app_theme.dart';
import 'package:desafio_bemol/core/utils/helpers.dart';
import 'package:flutter/material.dart';

class ProductDescriptionWidget extends StatelessWidget {
  final String category;
  final String description;

  const ProductDescriptionWidget({super.key, required this.category, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categoria
        Row(
          children: [
            Image.asset(
              'assets/images/category.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                Helpers.capitalize(category),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/descricion.png',
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                description,
                key: const Key('product_detail_description'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
