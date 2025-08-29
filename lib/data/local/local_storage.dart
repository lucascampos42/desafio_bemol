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
  
  Future<bool> saveFavorites(List<Product> favorites) async {
    try {
      AppLogger.info('Salvando ${favorites.length} favoritos no SharedPreferences...', LogTags.storage);
      final List<String> favoritesJson = favorites
          .map((product) => jsonEncode(product.toJson()))
          .toList();
      
      final result = await _prefs!.setStringList(AppConstants.favoritesKey, favoritesJson);
      AppLogger.info('Resultado do salvamento: $result', LogTags.storage);
      
      final saved = _prefs!.getStringList(AppConstants.favoritesKey);
      AppLogger.info('Verificação - itens salvos: ${saved?.length ?? 0}', LogTags.storage);
      
      return result;
    } catch (e) {
      AppLogger.error('Erro ao salvar favoritos', e, null, LogTags.storage);
      return false;
    }
  }
  
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
      AppLogger.error('Erro ao carregar favoritos', e, null, LogTags.storage);
      return [];
    }
  }
  
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
      AppLogger.error('Erro ao adicionar favorito', e, null, LogTags.storage);
      return false;
    }
  }
  
  Future<bool> removeFromFavorites(int productId) async {
    try {
      final List<Product> favorites = await loadFavorites();
      favorites.removeWhere((product) => product.id == productId);
      return await saveFavorites(favorites);
    } catch (e) {
      AppLogger.error('Erro ao remover favorito', e, null, LogTags.storage);
      return false;
    }
  }
  

  Future<bool> isFavorite(int productId) async {
    try {
      final List<Product> favorites = await loadFavorites();
      return favorites.any((product) => product.id == productId);
    } catch (e) {
      AppLogger.error('Erro ao verificar se produto é favorito', e, null, LogTags.storage);
      return false;
    }
  }
  

  Future<bool> clearFavorites() async {
    try {
      return await _prefs!.remove(AppConstants.favoritesKey);
    } catch (e) {
      AppLogger.error('Erro ao limpar favoritos', e, null, LogTags.storage);
      return false;
    }
  }
  

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