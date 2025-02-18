import 'package:flutter/material.dart';
import '../article/article_details_screen.dart';
import '../services/firebase_service.dart';
import '../models/news_category.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/feature_flags.dart';

class ExploreScreen extends StatefulWidget {
  static const routeName = '/explore';

  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<NewsCategory> _topics = [];
  bool _isLoading = true;
  List<String> _followedTopics = [];

  @override
  void initState() {
    super.initState();
    _loadTopics();
    _loadFollowedTopics();
  }

  Future<void> _loadTopics() async {
    try {
      final categories = await FirebaseService.getGNewsCategoriesFuture();
      setState(() {
        _topics = categories.where((topic) => topic.id != 'latest').toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading topics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFollowedTopics() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _followedTopics = List<String>.from(userDoc.data()?['followedTopics'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error loading followed topics: $e');
    }
  }

  Future<void> _toggleTopicSave(String topicId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        if (_followedTopics.contains(topicId)) {
          await userRef.update({
            'followedTopics': FieldValue.arrayRemove([topicId])
          });
          setState(() {
            _followedTopics.remove(topicId);
          });
        } else {
          await userRef.update({
            'followedTopics': FieldValue.arrayUnion([topicId])
          });
          setState(() {
            _followedTopics.add(topicId);
          });
        }
      } catch (e) {
        print('Error toggling topic save: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Topics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._topics.map((topic) => Column(
                    children: [
                      _buildTopicItem(
                        context,
                        topic.name ?? '',
                        topic.description ?? 'No description available',
                        topic.icon ?? 'assets/images/explore/default.png',
                        _followedTopics.contains(topic.id),
                        topic.id ?? '',
                      ),
                      const SizedBox(height: 12),
                    ],
                  )).toList(),
                  if (!FeatureFlags.isFeatureDisabled(FeatureFlags.EXPLORE_SCREEN_POPULAR_TOPIC)) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Popular Topic',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, ArticleDetailsScreen.routeName),
                      child: _buildPopularNewsItem(
                        context,
                        'Europe',
                        'Russian warship: Moskva sinks in Black Sea',
                        'BBC News',
                        '4h ago',
                        'assets/images/news1.jpg',
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildTopicItem(BuildContext context, String title, String description, String imageUrl, bool isSaved, String topicId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).cardColor,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/explore/default.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        color: const Color(0xFF246BFD),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 36,
              child: TextButton(
                onPressed: () => _toggleTopicSave(topicId),
                style: TextButton.styleFrom(
                  backgroundColor: isSaved ? const Color(0xFF246BFD) : Theme.of(context).cardColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSaved ? Colors.transparent : const Color(0xFF246BFD),
                    ),
                  ),
                  minimumSize: const Size(80, 36),
                ),
                child: Text(
                  isSaved ? 'Saved' : 'Save',
                  style: TextStyle(
                    color: isSaved ? Colors.white : const Color(0xFF246BFD),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularNewsItem(BuildContext context, String category, String title, String source, String time, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage(imageUrl),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      source,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
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