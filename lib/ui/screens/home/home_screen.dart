import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/product.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/product_list_widget.dart';
import '../../widgets/favorites_badge_widget.dart';
import '../product_detail/product_detail_screen.dart';
import '../favorites/favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ProductProvider _productProvider;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitializing = true;
  bool _hasConnectionError = false;

  @override
  void initState() {
    super.initState();
    _productProvider = ProductProvider();
    _searchController.addListener(_onSearchChanged);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _productProvider.ensureInitialized();
      
      await _productProvider.initializeWithApi().catchError((error) {
        // Se falhar por conexão, mostra imagem de erro
        debugPrint('Failed to load API data: $error');
        if (mounted) {
          setState(() {
            _hasConnectionError = true;
          });
        }
      });
    } catch (e) {
      debugPrint('Error during app initialization: $e');
      if (mounted) {
        setState(() {
          _hasConnectionError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _productProvider.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _productProvider.searchProducts(_searchController.text);
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          productProvider: _productProvider,
        ),
      ),
    );
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          productProvider: _productProvider,
        ),
      ),
    );
  }



  void _clearFilters() {
    _searchController.clear();
    _productProvider.clearFilters();
  }

  Future<void> _retryConnection() async {
    setState(() {
      _hasConnectionError = false;
      _isInitializing = true;
    });
    await _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Products',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
        centerTitle: false,
        actions: [
          ValueListenableBuilder(
            valueListenable: _productProvider,
            builder: (context, state, child) {
              return FavoritesBadgeWidget(
                onTap: _navigateToFavorites,
                hasFavorites: state.hasFavorites,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isInitializing
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing app...'),
                  ],
                ),
              )
            : _hasConnectionError
                 ? Center(
                     child: GestureDetector(
                       onTap: _retryConnection,
                       child: Image.asset(
                         'assets/images/erro.png',
                         width: 120,
                         height: 120,
                         fit: BoxFit.contain,
                         errorBuilder: (context, error, stackTrace) {
                           return const Icon(
                             Icons.wifi_off,
                             size: 64,
                             color: Colors.red,
                           );
                         },
                       ),
                     ),
                   )
                : ValueListenableBuilder(
                    valueListenable: _productProvider,
                    builder: (context, state, child) {
                      return RefreshIndicator(
                        onRefresh: _productProvider.refresh,
                        child: Column(
                          children: [
                            SearchBarWidget(
                              controller: _searchController,
                              isSearching: state.isSearching,
                              onClear: _clearFilters,
                            ),
                            Expanded(
                              child: ProductListWidget(
                                state: state,
                                scrollController: _scrollController,
                                onProductTap: _navigateToProductDetail,
                                onFavoriteToggle: _productProvider.toggleFavorite,
                                isFavorite: _productProvider.isFavorite,
                                onRefresh: _productProvider.refresh,
                                onClearSearch: _clearFilters,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }


}