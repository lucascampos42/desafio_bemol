import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/local/local_storage.dart';
import '../utils/logger.dart';
import '../utils/toast_helper.dart';

/// Gerenciador centralizado para operações de favoritos com persistência local
class FavoritesManager {
  final LocalStorage _localStorage;
  
  FavoritesManager(this._localStorage);
  
  /// Carrega lista de favoritos do armazenamento local
  Future<FavoritesResult> loadFavorites() async {
    try {
      final favorites = await _localStorage.loadFavorites();
      final favoriteIds = favorites.map((p) => p.id).toSet();
      
      AppLogger.success('${favorites.length} favoritos carregados do armazenamento local', LogTags.favorites);
      
      return FavoritesResult.success(
        favorites: favorites,
        favoriteIds: favoriteIds,
      );
    } catch (e) {
      AppLogger.error('Erro ao carregar favoritos do armazenamento local', e, null, LogTags.favorites);
      return FavoritesResult.error('Erro ao carregar favoritos. Verifique o armazenamento do dispositivo.');
    }
  }
  
  /// Adiciona produto aos favoritos com persistência e feedback
  Future<FavoriteToggleResult> addToFavorites(Product product, BuildContext? context) async {
    try {
      AppLogger.debug('➕ Adicionando produto aos favoritos: ${product.title} (ID: ${product.id})', LogTags.favorites);
      
      final success = await _localStorage.addToFavorites(product);
      
      if (success) {
        AppLogger.success('Produto adicionado aos favoritos com sucesso', LogTags.favorites);
        
        if (context != null && context.mounted) {
          ToastHelper.showSuccess(context, 'Added to favorites');
        }
        
        return FavoriteToggleResult.success(product.id, true);
      } else {
        return FavoriteToggleResult.error('Falha ao adicionar aos favoritos');
      }
    } catch (e) {
      AppLogger.error('Erro ao adicionar favorito', e, null, LogTags.favorites);
      
      if (context != null && context.mounted) {
        ToastHelper.showError(context, 'Error saving favorite. Try again.');
      }
      
      return FavoriteToggleResult.error('Erro ao atualizar favoritos. Tente novamente.');
    }
  }
  
  /// Remove produto dos favoritos com persistência e feedback
  Future<FavoriteToggleResult> removeFromFavorites(int productId, BuildContext? context) async {
    try {
      AppLogger.debug('➖ Removendo produto dos favoritos: ID $productId', LogTags.favorites);
      
      final success = await _localStorage.removeFromFavorites(productId);
      
      if (success) {
        AppLogger.success('Produto removido dos favoritos com sucesso', LogTags.favorites);
        
        if (context != null && context.mounted) {
          ToastHelper.showInfo(context, 'Removed from favorites');
        }
        
        return FavoriteToggleResult.success(productId, false);
      } else {
        return FavoriteToggleResult.error('Falha ao remover dos favoritos');
      }
    } catch (e) {
      AppLogger.error('Erro ao remover favorito', e, null, LogTags.favorites);
      
      if (context != null && context.mounted) {
        ToastHelper.showError(context, 'Error saving favorite. Try again.');
      }
      
      return FavoriteToggleResult.error('Erro ao atualizar favoritos. Tente novamente.');
    }
  }
  
  /// Verifica se um produto está nos favoritos
  Future<bool> isFavorite(int productId) async {
    try {
      return await _localStorage.isFavorite(productId);
    } catch (e) {
      AppLogger.error('Erro ao verificar se produto é favorito', e, null, LogTags.favorites);
      return false;
    }
  }
  
  /// Obtém IDs dos favoritos para performance
  Future<Set<int>> getFavoriteIds() async {
    try {
      return await _localStorage.getFavoriteIds();
    } catch (e) {
      AppLogger.error('Erro ao obter IDs dos favoritos', e, null, LogTags.favorites);
      return <int>{};
    }
  }
  
  /// Valida se o armazenamento local foi carregado corretamente
  Future<void> validateStorage() async {
    try {
      final savedFavorites = await _localStorage.loadFavorites();
      AppLogger.debug('Validação: ${savedFavorites.length} favoritos no armazenamento', LogTags.favorites);
    } catch (e) {
      AppLogger.warning('Falha na validação do armazenamento de favoritos', LogTags.favorites);
    }
  }
}

/// Resultado do carregamento de favoritos
class FavoritesResult {
  final List<Product>? favorites;
  final Set<int>? favoriteIds;
  final String? error;
  final bool isSuccess;
  
  const FavoritesResult._(
    this.favorites,
    this.favoriteIds,
    this.error,
    this.isSuccess,
  );
  
  factory FavoritesResult.success({
    required List<Product> favorites,
    required Set<int> favoriteIds,
  }) {
    return FavoritesResult._(favorites, favoriteIds, null, true);
  }
  
  factory FavoritesResult.error(String error) {
    return FavoritesResult._(null, null, error, false);
  }
}

/// Resultado da operação de toggle de favorito
class FavoriteToggleResult {
  final int? productId;
  final bool? isFavorite;
  final String? error;
  final bool isSuccess;
  
  const FavoriteToggleResult._(
    this.productId,
    this.isFavorite,
    this.error,
    this.isSuccess,
  );
  
  factory FavoriteToggleResult.success(int productId, bool isFavorite) {
    return FavoriteToggleResult._(productId, isFavorite, null, true);
  }
  
  factory FavoriteToggleResult.error(String error) {
    return FavoriteToggleResult._(null, null, error, false);
  }
}