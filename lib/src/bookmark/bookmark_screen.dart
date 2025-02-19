import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../article/article_details_screen.dart';
import '../services/firebase_service.dart';
import '../models/news_article.dart';
import '../models/news_category.dart';
import '../providers/auth_provider.dart';
import '../config/feature_flags.dart';
import '../services/shared_preferences_manager.dart';

class BookmarkScreen extends StatefulWidget {
  static const routeName = '/bookmark';

  const BookmarkScreen({super.key});

  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late Future<List<NewsArticle>> _bookmarkedArticles;
  Map<String, String> _categoryMap = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _bookmarkedArticles = _loadBookmarkedArticles();
  }

  Future<void> _loadCategories() async {
    final categories = await SharedPreferencesManager.getGNewsCategories();
    setState(() {
      _categoryMap = {
        for (var category in categories)
          category.id ?? '': category.name ?? ''
      };
    });
  }

  Future<List<NewsArticle>> _loadBookmarkedArticles() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userID = authProvider.userID;
    if (userID != null) {
      return FirebaseService.getAllBookmarks(userID: userID);
    } else {
      // Handle the case when the user is not logged in
      return [];
    }
  }

  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Uncategorized';
    return _categoryMap[categoryId] ?? categoryId;
  }

  Future<void> _removeBookmark(BuildContext context, NewsArticle article) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userID = authProvider.userID;
    if (userID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to remove bookmarks')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Bookmark'),
          content: const Text('Are you sure you want to remove this bookmark?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Remove'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await FirebaseService.removeBookmark(userID: userID, newsID: article.docID!);
        setState(() {
          _bookmarkedArticles = _loadBookmarkedArticles();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark removed successfully')),
        );
      } catch (e) {
        print('Failed to remove bookmark. Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove bookmark')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookmarks',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  if (!FeatureFlags.isFeatureDisabled(FeatureFlags.BOOKMARKS_SCREEN_SEARCH)) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                          prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                          suffixIcon: Icon(Icons.tune, color: Theme.of(context).iconTheme.color),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<NewsArticle>>(
                future: _bookmarkedArticles,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No bookmarked articles'));
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final article = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              ArticleDetailsScreen.routeName,
                              arguments: article,
                            );
                          },
                          child: _buildBookmarkItem(
                            context,
                            _getCategoryName(article.category),
                            article.title ?? 'No Title',
                            article.publisher ?? 'Unknown Source',
                            _formatTimestamp(article.timestamp ?? ''),
                            article.images?['thumbnail'] ?? '',
                            article,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final now = DateTime.now();
    final articleDate = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    final difference = now.difference(articleDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildBookmarkItem(
    BuildContext context,
    String category,
    String title,
    String source,
    String time,
    String imageUrl,
    NewsArticle article,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).cardColor,
                    child: Icon(Icons.image, color: Theme.of(context).iconTheme.color),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: Color(0xFF246BFD),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Theme.of(context).cardColor,
                      child: Icon(
                        Icons.person,
                        size: 12,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
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
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              size: 20,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () => _removeBookmark(context, article),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.share,
                              size: 20,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () {
                              // Implement share functionality
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
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