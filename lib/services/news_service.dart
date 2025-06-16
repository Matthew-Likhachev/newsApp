import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import 'package:flutter/foundation.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = 'a8fd92f04e7b431cb6fd937103bcdc5f';
  static const int _pageSize = 12;
  static const int _maxPages = 5; // Limit maximum pages to prevent rate limiting

  Future<Map<String, dynamic>> getNewsByCategory(String category, {int page = 1}) async {
    try {
      // Check if we've exceeded the maximum page limit
      if (page > _maxPages) {
        return {
          'articles': [],
          'hasMore': false,
          'totalResults': 0,
        };
      }

      String endpoint;
      Map<String, String> queryParams = {
        'apiKey': _apiKey,
        'language': 'en',
        'pageSize': _pageSize.toString(),
        'page': page.toString(),
      };

      switch (category.toLowerCase()) {
        case 'politics':
          queryParams['q'] = 'politics OR government OR election';
          endpoint = '/everything';
          break;
        case 'economy':
          queryParams['q'] = 'economy OR business OR finance OR market';
          endpoint = '/everything';
          break;
        case 'social':
          queryParams['q'] = 'society OR social OR community OR people';
          endpoint = '/everything';
          break;
        case 'culture':
          queryParams['q'] = 'culture OR arts OR entertainment OR music';
          endpoint = '/everything';
          break;
        case 'sports':
          queryParams['category'] = 'sports';
          endpoint = '/top-headlines';
          break;
        case 'technology':
          queryParams['category'] = 'technology';
          endpoint = '/top-headlines';
          break;
        case 'health':
          queryParams['category'] = 'health';
          endpoint = '/top-headlines';
          break;
        case 'science':
          queryParams['q'] = 'science OR research OR discovery';
          endpoint = '/everything';
          break;
        case 'entertainment':
          queryParams['q'] = 'entertainment OR movie OR music OR celebrity';
          endpoint = '/everything';
          break;
        default:
          endpoint = '/top-headlines';
          queryParams['country'] = 'us';
      }

      final url = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParams);
      debugPrint('Fetching news from: $url');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'error') {
          throw Exception(data['message'] ?? 'Unknown API error');
        }
        final List<dynamic> articles = data['articles'] ?? [];
        final totalResults = data['totalResults'] ?? 0;
        final hasMore = (page * _pageSize) < totalResults && page < _maxPages;
        
        debugPrint('Category: $category, Articles received: ${articles.length}, Total results: $totalResults');
        
        final newsArticles = articles.map((article) => NewsModel.fromJson(article)).toList();
        debugPrint('Processed articles: ${newsArticles.length}');
        
        return {
          'articles': newsArticles,
          'hasMore': hasMore,
          'totalResults': totalResults,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your API key configuration.');
      } else if (response.statusCode == 426) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load news: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in getNewsByCategory: $e');
      throw Exception('Error loading news: $e');
    }
  }
} 