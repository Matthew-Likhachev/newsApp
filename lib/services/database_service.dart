import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static SharedPreferences? _prefs;
  static const String _favoritesKey = 'favorites';

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> addFavorite(NewsModel article) async {
    await _initPrefs();
    final favorites = await getFavorites();
    if (!favorites.contains(article)) {
      favorites.add(article);
      await _saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(String url) async {
    await _initPrefs();
    final favorites = await getFavorites();
    favorites.removeWhere((article) => article.url == url);
    await _saveFavorites(favorites);
  }

  Future<bool> isFavorite(String url) async {
    await _initPrefs();
    final favorites = await getFavorites();
    return favorites.any((article) => article.url == url);
  }

  Future<List<NewsModel>> getFavorites() async {
    await _initPrefs();
    final favoritesJson = _prefs?.getStringList(_favoritesKey) ?? [];
    return favoritesJson
        .map((json) => NewsModel.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveFavorites(List<NewsModel> favorites) async {
    await _initPrefs();
    final favoritesJson = favorites
        .map((article) => jsonEncode(article.toJson()))
        .toList();
    await _prefs?.setStringList(_favoritesKey, favoritesJson);
  }
} 