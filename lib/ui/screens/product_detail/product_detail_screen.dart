import 'package:desafio_bemol/ui/widgets/product_description_widget.dart';
import 'package:desafio_bemol/ui/widgets/product_image_widget.dart';
import 'package:desafio_bemol/ui/widgets/product_rating_and_price_widget.dart';
import 'package:desafio_bemol/ui/widgets/product_title_and_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../core/utils/constants.dart';

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
                onPressed: () => productProvider.toggleFavorite(product, context),
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
            ProductImageWidget(imageUrl: product.image),
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductTitleAndCategoryWidget(title: product.title),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ProductRatingAndPriceWidget(rating: product.rating, price: product.price),
                  const SizedBox(height: AppConstants.largePadding),
                  ProductDescriptionWidget(category: product.category, description: product.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
