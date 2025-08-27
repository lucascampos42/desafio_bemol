import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../../core/utils/constants.dart';

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
      print('💾 Saving ${favorites.length} favorites to SharedPreferences...');
      final List<String> favoritesJson = favorites
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      
      final result = await _prefs!.setStringList(AppConstants.favoritesKey, favoritesJson);
      print('💾 Save result: $result');
      
      // Verificar se foi salvo
      final saved = _prefs!.getStringList(AppConstants.favoritesKey);
      print('💾 Verification - saved items count: ${saved?.length ?? 0}');
      
      return result;
    } catch (e) {
      print('❌ Error saving favorites: $e');
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
      print('Error loading favorites: $e');
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
      print('Error adding favorite: $e');
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
      print('Error removing favorite: $e');
      return false;
    }
  }
  
  /// Verifica se produto está nos favoritos
  Future<bool> isFavorite(int productId) async {
    try {
      final List<Product> favorites = await loadFavorites();
      return favorites.any((product) => product.id == productId);
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }
  
  /// Limpa todos os favoritos
  Future<bool> clearFavorites() async {
    try {
      return await _prefs!.remove(AppConstants.favoritesKey);
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }
  
  /// Obtém IDs dos favoritos (para performance)
  Future<Set<int>> getFavoriteIds() async {
    try {
      final List<Product> favorites = await loadFavorites();
      return favorites.map((product) => product.id).toSet();
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return <int>{};
    }
  }


}