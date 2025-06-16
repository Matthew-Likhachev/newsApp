import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import 'news_detail_screen.dart';
import '../widgets/theme_toggle_button.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle_button.dart';
import '../providers/favorites_provider.dart';
import 'favorites_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final NewsService _newsService = NewsService();
  final ScrollController _scrollController = ScrollController();
  List<NewsModel> _news = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  String _selectedTopic = 'All';

  final List<String> _topics = [
    'All',
    'Politics',
    'Economy',
    'Social',
    'Culture',
    'Sports',
    'Technology',
    'Health',
    'Science',
    'Entertainment'
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
    // Load favorites status for initial articles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesProvider>(context, listen: false).loadFavorites();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final result = await _newsService.getNewsByCategory(_selectedTopic, page: _currentPage);
      if (mounted) {
        debugPrint('News loaded for $_selectedTopic: ${result['articles'].length} articles');
        final articles = result['articles'] as List<NewsModel>;
        debugPrint('Articles before setting state: ${articles.length}');
        debugPrint('Article URLs: ${articles.map((a) => a.url).join('\n')}');
        
        setState(() {
          _news = articles;
          _hasMore = result['hasMore'];
          _isLoading = false;
        });
        debugPrint('Articles after setting state: ${_news.length}');
        
        // Check favorite status for loaded articles
        Provider.of<FavoritesProvider>(context, listen: false).checkFavoriteStatus(_news);
      }
    } catch (e) {
      debugPrint('Error loading news: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading news: $e')),
        );
      }
    }
  }

  void _goToPage(int page) {
    if (page < 1 || (page > _currentPage && !_hasMore)) return;
    
    setState(() {
      _currentPage = page;
      _isLoading = true;
    });
    
    _loadNews();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.getText('News Headlines', 'Новости')),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                final topic = _topics[index];
                final isSelected = topic == _selectedTopic;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(languageProvider.getText(
                      topic,
                      LanguageProvider.translations[topic] ?? topic,
                    )),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTopic = topic;
                        _currentPage = 1;
                        _loadNews();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadNews,
                    child: _news.isEmpty
                        ? Center(
                            child: Text(
                              languageProvider.getText(
                                'No news found for $_selectedTopic',
                                'Нет новостей для ${LanguageProvider.translations[_selectedTopic] ?? _selectedTopic}',
                              ),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    GridView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.all(8),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 0.7,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                      itemCount: _news.length,
                                      itemBuilder: (context, index) {
                                        final article = _news[index];
                                        return Consumer<FavoritesProvider>(
                                          builder: (context, favoritesProvider, child) {
                                            final isFavorite = favoritesProvider.isFavorite(article.url);
                                            return Card(
                                              clipBehavior: Clip.antiAlias,
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => NewsDetailScreen(article: article),
                                                    ),
                                                  );
                                                },
                                                child: Stack(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex: 3,
                                                          child: article.urlToImage.isNotEmpty
                                                              ? CachedNetworkImage(
                                                                  imageUrl: article.urlToImage,
                                                                  fit: BoxFit.cover,
                                                                  width: double.infinity,
                                                                  placeholder: (context, url) => const Center(
                                                                    child: CircularProgressIndicator(),
                                                                  ),
                                                                  errorWidget: (context, url, error) => Container(
                                                                    color: Colors.grey[300],
                                                                    child: const Icon(Icons.image_not_supported),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  color: Colors.grey[300],
                                                                  child: const Icon(Icons.image_not_supported),
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
                                                                  style: Theme.of(context).textTheme.titleSmall,
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                                const SizedBox(height: 4),
                                                                Text(
                                                                  article.description,
                                                                  style: Theme.of(context).textTheme.bodySmall,
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
                                                                        style: Theme.of(context).textTheme.bodySmall,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      article.publishedAt,
                                                                      style: Theme.of(context).textTheme.bodySmall,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                                              color: Colors.black.withAlpha(128),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: Icon(
                                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                                              color: isFavorite ? Colors.red : Colors.white,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      onPressed: _currentPage > 1
                                          ? () => _goToPage(_currentPage - 1)
                                          : null,
                                    ),
                                    Text(
                                      '${languageProvider.getText('Page', 'Страница')} $_currentPage',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed: _hasMore
                                          ? () => _goToPage(_currentPage + 1)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
          ),
        ],
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