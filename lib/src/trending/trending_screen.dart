import 'package:flutter/material.dart';
import '../article/article_webview_screen.dart';
import '../services/network_service.dart';

/// A widget that displays a list of trending news articles.
///
/// This screen fetches the latest news from the network service and displays
/// them in a scrollable list. It supports the following features:
/// * Pull-to-refresh functionality for updating news
/// * Loading state with progress indicator
/// * Error handling with retry option
/// * Responsive layout adapting to different screen sizes
/// * Theme-aware styling for light and dark modes
class TrendingScreen extends StatefulWidget {
  /// The route name for navigating to the TrendingScreen.
  /// Used in the app's routing system.
  static const routeName = '/trending';

  /// Creates a [TrendingScreen] widget.
  /// 
  /// This widget maintains its own state to handle news data loading,
  /// user interactions, and UI updates.
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  /// List of news items fetched from the network.
  /// 
  /// Each item is a map containing news article data such as:
  /// * title - The headline of the article
  /// * publisher - The source of the article
  /// * timestamp - Publication time in milliseconds since epoch
  /// * images - Map containing article images
  /// * snippet - Brief excerpt from the article
  List<dynamic> _newsItems = [];

  /// Indicates whether news data is currently being loaded.
  /// 
  /// Used to show/hide the loading indicator and manage UI states.
  bool _isLoading = true;

  /// Stores any error message that occurs during news fetching.
  /// 
  /// When non-null, indicates that an error occurred and displays
  /// the error message to the user with a retry option.
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  /// Fetches the latest news from the network service.
  ///
  /// This method:
  /// 1. Sets loading state to true
  /// 2. Clears any existing errors
  /// 3. Makes API call to fetch news
  /// 4. Updates state with fetched news or error message
  /// 
  /// The UI automatically updates to reflect loading states and results.
  Future<void> _fetchNews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await NetworkService.getLatestNews();
      if (response['status'] == 'success') {
        setState(() {
          _newsItems = response['items'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load news';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Converts a timestamp to a human-readable relative time string.
  ///
  /// Takes a [timestamp] in milliseconds since epoch and returns a formatted
  /// string representing the relative time, such as:
  /// * "2d ago" for days
  /// * "3h ago" for hours
  /// * "5m ago" for minutes
  /// * "Just now" for very recent times
  ///
  /// This provides users with an intuitive sense of article freshness.
  String _getTimeAgo(String timestamp) {
    final now = DateTime.now();
    final time = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    final difference = now.difference(time);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Trending',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color),
            onPressed: _fetchNews,
            tooltip: 'Refresh news',
          ),
        ],
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchNews,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNews,
                  child: ListView.builder(
                    itemCount: _newsItems.length,
                    itemBuilder: (context, index) {
                      final news = _newsItems[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticleWebViewScreen(
                                url: news['newsUrl'],
                                title: news['title'],
                              ),
                            ),
                          );
                        },
                        child: _buildNewsItem(
                          context,
                          'News',
                          news['title'],
                          news['publisher'],
                          _getTimeAgo(news['timestamp']),
                          news['images']?['thumbnailProxied'] ?? '',
                          news['snippet'],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  /// Builds a single news item card.
  ///
  /// This widget creates a card displaying a news article with the following elements:
  /// * [category] - The article category (e.g., "News", "Sports")
  /// * [title] - The main headline of the article
  /// * [source] - The publisher or source of the article
  /// * [time] - Relative time since publication
  /// * [imageUrl] - URL of the article's thumbnail image
  /// * [snippet] - Brief excerpt or summary of the article
  ///
  /// The card features:
  /// * Responsive image handling with error states
  /// * Theme-aware styling
  /// * Text overflow handling
  /// * Touch feedback for interaction
  /// * Proper spacing and typography
  Widget _buildNewsItem(
    BuildContext context,
    String category,
    String title,
    String source,
    String time,
    String imageUrl,
    String snippet,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Article thumbnail image with error handling
            ///
            /// Displays the article's thumbnail image in a rounded container.
            /// Features:
            /// * Responsive sizing with fixed height
            /// * Error state with fallback icon
            /// * Rounded corners on top edges only
            /// * Proper image scaling and cropping
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            /// Article content container
            ///
            /// Contains the article's textual content with proper spacing
            /// and typography. Includes category, title, snippet, and metadata.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Category label
                  ///
                  /// Displays the article category with distinctive styling
                  /// Features:
                  /// * Accent color for visibility
                  /// * Medium weight for emphasis
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF246BFD),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  /// Article title
                  ///
                  /// Main headline of the article with prominent styling
                  /// Features:
                  /// * Larger font size for hierarchy
                  /// * Bold weight for emphasis
                  /// * Theme-aware color adaptation
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  /// Article snippet
                  ///
                  /// Brief excerpt from the article with controlled length
                  /// Features:
                  /// * Limited to 3 lines with ellipsis
                  /// * Slightly muted color for hierarchy
                  /// * Proper line height for readability
                  Text(
                    snippet,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  /// Article metadata row
                  ///
                  /// Contains source, timestamp, and action buttons
                  /// Features:
                  /// * Flexible layout for varying content lengths
                  /// * Proper spacing between elements
                  /// * Theme-aware styling
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Source avatar
                      ///
                      /// Visual identifier for the article source
                      /// Features:
                      /// * Circular shape
                      /// * Theme-aware colors
                      /// * Fallback icon
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(Icons.person, size: 16, color: Theme.of(context).iconTheme.color),
                      ),
                      const SizedBox(width: 8),
                      /// Source and time container
                      ///
                      /// Flexible container for source name and timestamp
                      /// Features:
                      /// * Proper overflow handling
                      /// * Flexible layout
                      /// * Consistent spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Source name
                            ///
                            /// Publisher name with multiline support
                            /// Features:
                            /// * Medium weight for emphasis
                            /// * Theme-aware color
                            Text(
                              source,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            /// Timestamp
                            ///
                            /// Relative time indicator
                            /// Features:
                            /// * Muted color for secondary information
                            /// * Consistent formatting
                            Text(
                              time,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      /// More options button
                      ///
                      /// Action button for additional options
                      /// Features:
                      /// * Theme-aware icon color
                      /// * Tooltip for accessibility
                      /// * Touch target sizing
                      IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {},
                        tooltip: 'More options',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}