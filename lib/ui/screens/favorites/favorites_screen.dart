import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_widgets.dart';
import '../error/error_screen.dart';
import '../product_detail/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final ProductProvider productProvider;

  const FavoritesScreen({
    super.key,
    required this.productProvider,
  });

  void _navigateToProductDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          productProvider: productProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productProvider.clearError();
      productProvider.loadFavoritesOnly();
    });
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'Favorites',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: productProvider,
        builder: (context, state, child) {
          if (state.isLoadingFavorites) {
            return const LoadingWidget(message: 'Loading favorites...');
          }

          if (state.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ErrorScreen()),
              );
            });
            return const SizedBox.shrink();
          }

          if (!state.hasFavorites) {
            return Center(
              child: Image.asset(
                'assets/images/empty.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.favorite_border,
                    size: 64,
                  );
                },
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: productProvider.loadFavoritesOnly,
            child: _buildFavoritesList(context, state),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, state) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final product = state.favorites[index];
        return ProductCard(
          product: product,
          isFavorite: true,
          onTap: () => _navigateToProductDetail(context, product),
          onFavoriteToggle: () => productProvider.toggleFavorite(product),
        );
      },
    );
  }
}