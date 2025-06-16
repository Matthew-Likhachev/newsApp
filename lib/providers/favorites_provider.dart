import 'package:flutter/foundation.dart';
import '../models/news_model.dart';
import '../services/database_service.dart';

class FavoritesProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<NewsModel> _favorites = [];
  Map<String, bool> _favoriteStatus = {};

  Future<List<NewsModel>> get favorites async {
    if (_favorites.isEmpty) {
      await loadFavorites();
    }
    return _favorites;
  }

  bool isFavorite(String url) => _favoriteStatus[url] ?? false;

  FavoritesProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      _favorites = await _databaseService.getFavorites();
      _favoriteStatus = {
        for (var article in _favorites) article.url: true
      };
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(NewsModel article) async {
    try {
      final isCurrentlyFavorite = _favoriteStatus[article.url] ?? false;
      
      if (isCurrentlyFavorite) {
        await _databaseService.removeFavorite(article.url);
        _favorites.removeWhere((a) => a.url == article.url);
        _favoriteStatus[article.url] = false;
      } else {
        await _databaseService.addFavorite(article);
        _favorites.add(article);
        _favoriteStatus[article.url] = true;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> checkFavoriteStatus(List<NewsModel> articles) async {
    try {
      for (var article in articles) {
        if (!_favoriteStatus.containsKey(article.url)) {
          _favoriteStatus[article.url] = await _databaseService.isFavorite(article.url);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
    }
  }
} 