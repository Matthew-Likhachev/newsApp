import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../models/news_model.dart';
import 'news_detail_screen.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/language_toggle_button.dart';
import '../providers/language_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getText('Favorite Articles', 'Избранные статьи')),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          return FutureBuilder<List<NewsModel>>(
            future: favoritesProvider.favorites,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final favorites = snapshot.data ?? [];
              
              // Debug logging for favorites
              debugPrint('Favorites in database: ${favorites.length}');
              for (var article in favorites) {
                debugPrint('Article: ${article.title}');
              }

              if (favorites.isEmpty) {
                return Center(
                  child: Text(
                    languageProvider.getText(
                      'No favorite articles yet',
                      'Нет избранных статей',
                    ),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final article = favorites[index];
                  return Stack(
                    children: [
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewsDetailScreen(article: article),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: article.urlToImage.isNotEmpty
                                        ? Image.network(
                                            article.urlToImage,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: theme.colorScheme.surfaceContainerHighest,
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.title,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              color: theme.textTheme.titleSmall?.color,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            article.description,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.textTheme.bodySmall?.color,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  article.source,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.textTheme.bodySmall?.color,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                article.publishedAt,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.textTheme.bodySmall?.color,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => favoritesProvider.toggleFavorite(article),
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface.withAlpha(128),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.delete,
                                      color: theme.colorScheme.onSurface,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          LanguageToggleButton(),
          SizedBox(width: 16),
          ThemeToggleButton(),
        ],
      ),
    );
  }
} 