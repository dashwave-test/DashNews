import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../trending/trending_screen.dart';
import '../notifications/notification_screen.dart';
import '../search/search_screen.dart';
import '../explore/explore_screen.dart';
import '../bookmark/bookmark_screen.dart';
import '../article/article_details_screen.dart';
import '../article/article_webview_screen.dart';
import '../auth/profile_screen.dart';
import '../services/firebase_service.dart';
import '../models/news_category.dart';
import '../models/news_article.dart';
import '../services/network_service.dart';
import '../config/feature_flags.dart';
import 'category_based_news_screen.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Widget> _screens = [
    const _HomeTab(),
    const ExploreScreen(),
    const BookmarkScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String? _selectedCategoryId;
  List<NewsCategory> _categories = [];
  bool _isLoadingCategories = true;
  bool _isLoadingLatestNews = false;
  bool _isLoadingTrendingNews = false;
  bool _isLoadingMoreNews = false;
  String? _categoriesError;
  String? _latestNewsError;
  String? _trendingNewsError;
  List<NewsArticle> _latestNewsItems = [];
  List<NewsArticle> _trendingNewsItems = [];
  Map<String, DocumentSnapshot?> _lastDocuments = {};
  Map<String, List<NewsArticle>> _categoryNewsItems = {};
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (FeatureFlags.isFeatureEnabled(FeatureFlags.HOME_SCREEN_TRENDING)) {
      _loadTrendingNews();
    }
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 1000 && !_showScrollToTopButton) {
      setState(() {
        _showScrollToTopButton = true;
      });
    } else if (_scrollController.offset < 1000 && _showScrollToTopButton) {
      setState(() {
        _showScrollToTopButton = false;
      });
    }

    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreLatestNews();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      final Duration difference = DateTime.now().difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoadingCategories = true;
        _categoriesError = null;
      });
      
      final categories = await FirebaseService.getGNewsCategoriesFuture();
      setState(() {
        _categories = _sortCategories(categories);
        _isLoadingCategories = false;
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories[0].id;
          _loadLatestNews(_selectedCategoryId!);
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
        _categoriesError = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Failed to load categories. Please try again later.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadCategories,
            ),
          ),
        );
      }
    }
  }

  List<NewsCategory> _sortCategories(List<NewsCategory> categories) {
    final allCategory = categories.firstWhere(
      (category) => category.alias?.toLowerCase() == 'all',
      orElse: () => NewsCategory(),
    );

    if (allCategory.id != null) {
      categories.remove(allCategory);
      categories.insert(0, allCategory);
    }

    return categories;
  }

  Future<void> _loadTrendingNews() async {
    try {
      setState(() {
        _isLoadingTrendingNews = true;
        _trendingNewsError = null;
      });

      final result = await FirebaseService.getPaginatedNews(
        categoryID: 'trending',
        startPage: 0,
        count:30,
      );
      setState(() {
        _trendingNewsItems = result.articles;
        _lastDocuments['trending'] = result.lastDocument;
        _isLoadingTrendingNews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTrendingNews = false;
        _trendingNewsError = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load trending news. Please try again later.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadLatestNews(String categoryId) async {
    try {
      setState(() {
        _isLoadingLatestNews = true;
        _latestNewsError = null;
      });

      final result = await FirebaseService.getPaginatedNews(
        categoryID: categoryId,
        startPage: 0,
        count: 10, // Load 10 articles at a time
        lastDoc: _lastDocuments[categoryId],
      );
      print("Latest news count = ${result.articles.length}");
      setState(() {
        _latestNewsItems = result.articles;
        _lastDocuments[categoryId] = result.lastDocument;
        _categoryNewsItems[categoryId] = result.articles;
        _isLoadingLatestNews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLatestNews = false;
        _latestNewsError = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load latest news. Please try again later. ${e}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreLatestNews() async {
    if (_isLoadingMoreNews || _selectedCategoryId == null) return;

    try {
      setState(() {
        _isLoadingMoreNews = true;
      });

      final lastDoc = _lastDocuments[_selectedCategoryId];
      if (lastDoc == null) return;

      final result = await FirebaseService.getPaginatedNews(
        categoryID: _selectedCategoryId!,
        startPage: 0,
        count: 10, // Load 10 articles at a time
        lastDoc: lastDoc,
      );

      if (result.articles.isNotEmpty) {
        setState(() {
          final currentItems = _categoryNewsItems[_selectedCategoryId] ?? [];
          _categoryNewsItems[_selectedCategoryId!] = [...currentItems, ...result.articles];
          _lastDocuments[_selectedCategoryId!] = result.lastDocument;
        });
      }

      setState(() {
        _isLoadingMoreNews = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMoreNews = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more news. Please try again later.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildCategoriesSection() {
    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categoriesError != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load categories',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _loadCategories,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: _categories.map((category) {
          final categoryLabel = category.alias?.isNotEmpty == true ? category.alias : category.name;
          if (categoryLabel == null || categoryLabel.isEmpty) {
            return const SizedBox.shrink(); // Skip this category
          }
          return _CategoryChip(
            label: categoryLabel,
            isSelected: category.id == _selectedCategoryId,
            context: context,
            onSelected: (selected) {
              setState(() {
                _selectedCategoryId = category.id;
                if (_selectedCategoryId != null) {
                  _loadLatestNews(_selectedCategoryId!);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLatestNewsSection() {
    if (_isLoadingLatestNews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_latestNewsError != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load latest news',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  if (_selectedCategoryId != null) {
                    _loadLatestNews(_selectedCategoryId!);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final newsItems = _selectedCategoryId != null ? (_categoryNewsItems[_selectedCategoryId] ??[]) : _latestNewsItems;

    return Column(
      children: [...newsItems.map((newsItem) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleWebViewScreen(
                    url: newsItem.newsUrl ?? '',
                    title:newsItem.title ?? '',
                  ),
                ),
              );
            },
            child: _buildLatestNewsItem(
              context,
              newsItem.title ?? '',
              newsItem.publisher ?? '',
              newsItem.timestamp ?? '',
              newsItem.images?['thumbnailProxied'] ?? newsItem.images?['thumbnail'] ?? 'assets/images/news1.jpg',
              newsItem.newsUrl ?? '',
            ),
          );
        }).toList(),
        if (_isLoadingMoreNews)
          const Padding(padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Ka',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.article_outlined,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'bar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          if (FeatureFlags.isFeatureEnabled(FeatureFlags.HOME_SCREEN_NOTIFICATIONS))
            IconButton(
              icon: Icon(Icons.notifications_none_outlined, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                Navigator.pushNamed(context, NotificationScreen.routeName);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (FeatureFlags.isFeatureEnabled(FeatureFlags.HOME_SCREEN_SEARCH))
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, SearchScreen.routeName);
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                            suffixIcon: Icon(Icons.tune, color: Theme.of(context).iconTheme.color),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (FeatureFlags.isFeatureEnabled(FeatureFlags.HOME_SCREEN_TRENDING)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trending',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, TrendingScreen.routeName);
                          },
                          child: Text(
                            'See all',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_trendingNewsItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleWebViewScreen(
                                url: _trendingNewsItems[0].newsUrl ?? '',
                                title: _trendingNewsItems[0].title ?? '',
                              ),
                            ),
                          );
                        },
                        child: _buildNewsCard(
                          context,
                          _trendingNewsItems[0].category ?? '',
                          _trendingNewsItems[0].title ?? '',
                          _trendingNewsItems[0].publisher ?? '',
                          _trendingNewsItems[0].timestamp ?? '',
                          _trendingNewsItems[0].images?['thumbnailProxied'] ?? _trendingNewsItems[0].images?['thumbnail'] ?? 'assets/images/news1.jpg',
                          _trendingNewsItems[0].newsUrl ?? '',
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_selectedCategoryId != null) {
                            final selectedCategory = _categories.firstWhere(
                              (category) => category.id == _selectedCategoryId,
                              orElse: () => NewsCategory(name: 'Latest'),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryBasedNewsScreen(
                                  categoryId: _selectedCategoryId!,
                                  categoryName: selectedCategory.name ?? 'Latest',
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'See all',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCategoriesSection(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildLatestNewsSection(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (_showScrollToTopButton)
            Positioned(
              right: 16,
              bottom: 16,
              child: AnimatedOpacity(
                opacity: _showScrollToTopButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: FloatingActionButton(
                  onPressed: _scrollToTop,
                  mini: true,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, String category, String title, String source, String time, String imageUrl, String newsUrl) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/news1.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).cardColor,
                      child: Icon(Icons.person, size: 16, color: Theme.of(context).iconTheme.color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      source,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _formatTimestamp(time),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.bookmark_outline,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        // Add bookmark functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Article bookmarked')),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        Share.share('Check out this article: $newsUrl');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestNewsItem(BuildContext context, String title, String source, String time, String imageUrl, String newsUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/news1.jpg',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Theme.of(context).cardColor,
                            child: Icon(Icons.person, size: 12, color: Theme.of(context).iconTheme.color),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              source,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(time),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.bookmark_outline,
                        size: 20,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        // Add bookmark functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Article bookmarked')),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.share,
                        size: 20,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        Share.share('Check out this article: $newsUrl');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _CategoryChip({
  required String label,
  bool isSelected = false,
  required BuildContext context,
  required Function(bool) onSelected,
}) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      showCheckmark: true,
      checkmarkColor: Colors.white,
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
        ),
      ),
    ),
  );
}