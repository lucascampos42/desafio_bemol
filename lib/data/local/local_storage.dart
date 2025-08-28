import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/logger.dart';

class LocalStorage {
  static LocalStorage? _instance;
  static SharedPreferences? _prefs;
  
  LocalStorage._();
  
  static Future<LocalStorage> getInstance() async {
    _instance ??= LocalStorage._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  /// Salva lista de produtos favoritos
  Future<bool> saveFavorites(List<Product> favorites) async {
    try {
      AppLogger.info('Saving ${favorites.length} favorites to SharedPreferences...', LogTags.storage);
      final List<String> favoritesJson = favorites
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      
      final result = await _prefs!.setStringList(AppConstants.favoritesKey, favoritesJson);
      AppLogger.info('Save result: $result', LogTags.storage);
      
      final saved = _prefs!.getStringList(AppConstants.favoritesKey);
      AppLogger.info('Verification - saved items count: ${saved?.length ?? 0}', LogTags.storage);
      
      return result;
    } catch (e) {
      AppLogger.error('Error saving favorites', e, null, LogTags.storage);
      return false;
    }
  }
  
  /// Carrega lista de produtos favoritos
  Future<List<Product>> loadFavorites() async {
    try {
      final List<String>? favoritesJson = _prefs!.getStringList(AppConstants.favoritesKey);
      
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }
      
      return favoritesJson
          .map((json) => Product.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      AppLogger.error('Error loading favorites', e, null, LogTags.storage);
      return [];
    }
  }
  
  /// Adiciona produto aos favoritos
  Future<bool> addToFavorites(Product product) async {
    try {
      final List<Product> favorites = await loadFavorites();
      
      // Verifica se já não está nos favoritos
      if (!favorites.any((fav) => fav.id == product.id)) {
        favorites.add(product);
        return await saveFavorites(favorites);
      }
      
      return true;
    } catch (e) {
      AppLogger.error('Error adding favorite', e, null, LogTags.storage);
      return false;
    }
  }
  
  /// Remove produto dos favoritos
  Future<bool> removeFromFavorites(int productId) async {
    try {
      final List<Product> favorites = await loadFavorites();
      favorites.removeWhere((product) => product.id == productId);
      return await saveFavorites(favorites);
    } catch (e) {
      AppLogger.error('Error removing favorite', e, null, LogTags.storage);
      return false;
    }
  }
  
  /// Verifica se produto está nos favoritos
  Future<bool> isFavorite(int productId) async {
    try {
      final List<Product> favorites = await loadFavorites();
      return favorites.any((product) => product.id == productId);
    } catch (e) {
      AppLogger.error('Erro ao verificar se produto é favorito', e, null, LogTags.storage);
      return false;
    }
  }
  
  /// Limpa todos os favoritos
  Future<bool> clearFavorites() async {
    try {
      return await _prefs!.remove(AppConstants.favoritesKey);
    } catch (e) {
      AppLogger.error('Erro ao limpar favoritos', e, null, LogTags.storage);
      return false;
    }
  }
  
  /// Obtém IDs dos favoritos (para performance)
  Future<Set<int>> getFavoriteIds() async {
    try {
      final List<Product> favorites = await loadFavorites();
      return favorites.map((product) => product.id).toSet();
    } catch (e) {
      AppLogger.error('Erro ao obter IDs dos favoritos', e, null, LogTags.storage);
      return <int>{};
    }
  }


}