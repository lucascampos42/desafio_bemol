import 'package:desafio_bemol/ui/widgets/product_description_widget.dart';
import 'package:desafio_bemol/ui/widgets/product_image_widget.dart';
import 'package:desafio_bemol/ui/widgets/product_rating_and_price_widget.dart';
import 'package:desafio_bemol/ui/widgets/product_title_and_category_widget.dart';
import 'package:flutter/material.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/performance_metrics.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ProductProvider productProvider;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.productProvider,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    PerformanceMetrics.instance.trackScreenNavigation(
      'product_detail_loaded',
      {
        'product_id': widget.product.id.toString(),
        'product_category': widget.product.category,
        'product_price': widget.product.price.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: widget.productProvider,
            builder: (context, state, child) {
              final isFavorite = widget.productProvider.isFavorite(widget.product.id);
              return IconButton(
                onPressed: () => widget.productProvider.toggleFavorite(widget.product, context),
                icon: AppAnimations.favoriteHeart(
                  isFavorite: isFavorite,
                  onTap: () => widget.productProvider.toggleFavorite(widget.product, context),
                  size: 24,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: AppAnimations.fadeSlideIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAnimations.fadeIn(
                child: ProductImageWidget(imageUrl: widget.product.image),
              ),
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAnimations.fadeSlideIn(
                      child: ProductTitleAndCategoryWidget(title: widget.product.title),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    AppAnimations.fadeSlideIn(
                      child: ProductRatingAndPriceWidget(rating: widget.product.rating, price: widget.product.price),
                    ),
                    const SizedBox(height: AppConstants.largePadding),
                    AppAnimations.fadeSlideIn(
                      child: ProductDescriptionWidget(category: widget.product.category, description: widget.product.description),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
