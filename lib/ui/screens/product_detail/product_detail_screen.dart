import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/constants.dart';
import '../../../core/theme/app_theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final ProductProvider productProvider;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.productProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: productProvider,
            builder: (context, state, child) {
              final isFavorite = productProvider.isFavorite(product.id);
              return IconButton(
                onPressed: () => productProvider.toggleFavorite(product),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Image unavailable',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Conteúdo do produto
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e categoria
                  _buildTitleAndCategory(context),
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  // Rating e preço
                  _buildRatingAndPrice(context),
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Descrição
                  _buildDescription(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildTitleAndCategory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          product.title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.0,
            letterSpacing: 0.0,
            // color #000000
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRatingAndPrice(BuildContext context) {
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
                  Helpers.formatRating(product.rating.rate),
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
                  '(${product.rating.count} reviews)',
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
                Helpers.formatPrice(product.price),
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

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categoria
        Container(
          child: Row(
            children: [
              Image.asset(
                'assets/images/category.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Helpers.capitalize(product.category),
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
                product.description,
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