import 'package:desafio_bemol/core/theme/app_theme.dart';
import 'package:desafio_bemol/core/utils/helpers.dart';
import 'package:desafio_bemol/data/models/product.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductRatingAndPriceWidget extends StatelessWidget {
  final Rating rating;
  final double price;

  const ProductRatingAndPriceWidget({super.key, required this.rating, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rating
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  Helpers.formatRating(rating.rate),
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.21,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${rating.count} reviews)',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.21,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          
          // Preço
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Helpers.formatPrice(price),
                key: const Key('product_detail_price'),
                style: GoogleFonts.poppins(
                  fontSize: 29,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5EC401),
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
