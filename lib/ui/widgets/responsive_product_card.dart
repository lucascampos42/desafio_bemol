import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/product.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/responsive_helper.dart';

/// Card de produto responsivo que se adapta ao tamanho da tela
/// Em mobile: layout horizontal (como o atual)
/// Em desktop: layout vertical tipo card para melhor aproveitamento do espaço
class ResponsiveProductCard extends StatefulWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const ResponsiveProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  State<ResponsiveProductCard> createState() => _ResponsiveProductCardState();
}

class _ResponsiveProductCardState extends State<ResponsiveProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.responsive(
      context: context,
      mobile: _buildMobileCard(),
      tablet: _buildDesktopCard(),
      desktop: _buildDesktopCard(),
    );
  }

  /// Layout horizontal para mobile (mantém o design atual)
  Widget _buildMobileCard() {
    return AppAnimations.fadeSlideIn(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 235, 234, 234),
                    width: 0.5,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: widget.onTap,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImage(120, 120),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: SizedBox(
                          height: 146,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProductInfo(),
                              const Spacer(),
                              _buildPriceAndFavorite(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Layout vertical tipo card para desktop/tablet
  Widget _buildDesktopCard() {
    return AppAnimations.fadeSlideIn(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem do produto (ocupa mais espaço em desktop)
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        child: _buildProductImage(double.infinity, double.infinity),
                      ),
                    ),
                    // Informações do produto
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProductInfo(isDesktop: true),
                            const Spacer(),
                            _buildPriceAndFavorite(isDesktop: true),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductImage(double width, double height) {
    return Container(
      margin: ResponsiveHelper.isMobile(context) 
          ? const EdgeInsets.only(top: 12) 
          : EdgeInsets.zero,
      height: height == double.infinity ? null : height,
      width: width == double.infinity ? null : width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: widget.product.image,
          fit: BoxFit.contain,
          placeholder: (context, url) => Center(
            child: AppAnimations.rotatingLoader(size: 30),
          ),
          errorWidget: (context, url, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: ResponsiveHelper.isMobile(context) ? 30 : 40,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 4),
                Text(
                  'Image\nunavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.isMobile(context) ? 9 : 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo({bool isDesktop = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.title,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            height: 1.2,
          ),
          maxLines: isDesktop ? 3 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        if (isDesktop) ...[
          // Em desktop, mostra mais informações
          Text(
            widget.product.category.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: isDesktop ? 18 : 16,
            ),
            const SizedBox(width: 4),
            Text(
              widget.product.rating.rate.toStringAsFixed(1),
              style: TextStyle(
                fontSize: isDesktop ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${widget.product.rating.count})',
              style: TextStyle(
                fontSize: isDesktop ? 12 : 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceAndFavorite({bool isDesktop = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '\$${widget.product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        AppAnimations.favoriteHeart(
          isFavorite: widget.isFavorite,
          onTap: widget.onFavoriteToggle,
          size: isDesktop ? 28 : 24,
        ),
      ],
    );
  }
}