import 'package:flutter/material.dart';
import '../article/article_details_screen.dart';

class TrendingScreen extends StatelessWidget {
  static const routeName = '/trending';

  const TrendingScreen({super.key});

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
            icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ArticleDetailsScreen.routeName),
            child: _buildNewsItem(
              context,
              'Europe',
              'Russian warship: Moskva sinks in Black Sea',
              'BBC News',
              '4h ago',
              'assets/images/news1.jpg',
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ArticleDetailsScreen.routeName),
            child: _buildNewsItem(
              context,
              'Europe',
              'Ukraine\'s President Zelensky to BBC: Blood money being paid for Russian oil',
              'BBC News',
              '14m ago',
              'assets/images/news2.jpg',
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ArticleDetailsScreen.routeName),
            child: _buildNewsItem(
              context,
              'Travel',
              'Her train broke down. Her phone died. And then she met her future husband',
              'CNN',
              '1h ago',
              'assets/images/news3.jpg',
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ArticleDetailsScreen.routeName),
            child: _buildNewsItem(
              context,
              'Money',
              'Wind power produced more electricity than coal and nuclear combined',
              'USA Today',
              '4h ago',
              'assets/images/news4.jpg',
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ArticleDetailsScreen.routeName),
            child: _buildNewsItem(
              context,
              'Life',
              'We keep rising to new challenges: For churches hit by disasters, rebuilding is an act of faith',
              'USA Today',
              '4h ago',
              'assets/images/news5.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, String category, String title, String source, String time, String imageUrl) {
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF246BFD),
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
                        time,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {},
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