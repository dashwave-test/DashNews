import 'package:flutter/material.dart';
import '../author/author_profile_screen.dart';
import '../article/article_details_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<TopicItem> _topics = [
    TopicItem(
      title: 'Health',
      description: 'View the latest health news and explore articles on...',
      image: 'assets/images/topics/health.png',
      isSaved: false,
    ),
    TopicItem(
      title: 'Technology',
      description: 'The latest tech news about the world\'s best hardware...',
      image: 'assets/images/topics/technology.png',
      isSaved: true,
    ),
    TopicItem(
      title: 'Art',
      description: 'The Art Newspaper is the journal of record for...',
      image: 'assets/images/topics/art.png',
      isSaved: true,
    ),
    TopicItem(
      title: 'Politics',
      description: 'Opinion and analysis of American and global polit...',
      image: 'assets/images/topics/politics.png',
      isSaved: false,
    ),
    TopicItem(
      title: 'Sport',
      description: 'Sports news and live sports coverage including scores..',
      image: 'assets/images/topics/sport.png',
      isSaved: false,
    ),
    TopicItem(
      title: 'Travel',
      description: 'The latest travel news on the most significant developm...',
      image: 'assets/images/topics/travel.png',
      isSaved: false,
    ),
    TopicItem(
      title: 'Money',
      description: 'The latest breaking financial news on the US and world...',
      image: 'assets/images/topics/money.png',
      isSaved: false,
    ),
  ];

  final List<AuthorItem> _authors = [
    AuthorItem(
      name: 'BBC News',
      followers: '1.2M',
      image: 'assets/images/authors/bbc.png',
      isFollowing: true,
    ),
    AuthorItem(
      name: 'CNN',
      followers: '959K',
      image: 'assets/images/authors/cnn.png',
      isFollowing: false,
    ),
    AuthorItem(
      name: 'Vox',
      followers: '452K',
      image: 'assets/images/authors/vox.png',
      isFollowing: true,
    ),
    AuthorItem(
      name: 'USA Today',
      followers: '325K',
      image: 'assets/images/authors/usa_today.png',
      isFollowing: true,
    ),
    AuthorItem(
      name: 'CNBC',
      followers: '21K',
      image: 'assets/images/authors/cnbc.png',
      isFollowing: false,
    ),
    AuthorItem(
      name: 'CNET',
      followers: '18K',
      image: 'assets/images/authors/cnet.png',
      isFollowing: false,
    ),
    AuthorItem(
      name: 'MSN',
      followers: '15K',
      image: 'assets/images/authors/msn.png',
      isFollowing: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 2; // Start with Author tab selected
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Input tel',
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF246BFD),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF246BFD),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'News'),
              Tab(text: 'Topics'),
              Tab(text: 'Author'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewsTab(),
          _buildTopicsTab(),
          _buildAuthorTab(),
        ],
      ),
    );
  }

  Widget _buildAuthorTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _authors.length,
      itemBuilder: (context, index) {
        final author = _authors[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuthorProfileScreen(
                  name: author.name,
                  followers: author.followers,
                  image: author.image,
                  isFollowing: author.isFollowing,
                  description: 'is an operational business division of the British Broadcasting Corporation responsible for the gathering and broadcasting of news and current affairs.',
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      author.image,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${author.followers} Followers',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        author.isFollowing = !author.isFollowing;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: author.isFollowing ? const Color(0xFF246BFD) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: author.isFollowing ? Colors.transparent : const Color(0xFF246BFD),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(72, 36),
                    ),
                    child: Text(
                      author.isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: author.isFollowing ? Colors.white : const Color(0xFF246BFD),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
  }

  Widget _buildNewsTab() {
    return ListView(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ArticleDetailsScreen.routeName),
          child: _buildNewsItem(
            'Europe',
            'Ukraine\'s President Zelensky to BBC: Blood money being paid for Russian...',
            'BBC News',
            '14m ago',
            'assets/images/news2.jpg',
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ArticleDetailsScreen.routeName),
          child: _buildNewsItem(
            'Travel',
            'Russian warship: Moskva sinks in Black Sea',
            'BBC News',
            '1h ago',
            'assets/images/news1.jpg',
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ArticleDetailsScreen.routeName),
          child: _buildNewsItem(
            'Travel',
            'Her train broke down. Her phone died. And then she met her future husband',
            'CNN',
            '1h ago',
            'assets/images/news3.jpg',
          ),
        ),
      ],
    );
  }

  Widget _buildNewsItem(String category, String title, String source, String time, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: AssetImage(imageUrl),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      source,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, size: 20),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    topic.image,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 72,
                height: 32,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      topic.isSaved = !topic.isSaved;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: topic.isSaved ? const Color(0xFF246BFD) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: topic.isSaved ? Colors.transparent : const Color(0xFF246BFD),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    topic.isSaved ? 'Saved' : 'Save',
                    style: TextStyle(
                      color: topic.isSaved ? Colors.white : const Color(0xFF246BFD),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TopicItem {
  final String title;
  final String description;
  final String image;
  bool isSaved;

  TopicItem({
    required this.title,
    required this.description,
    required this.image,
    required this.isSaved,
  });
}

class AuthorItem {
  final String name;
  final String followers;
  final String image;
  bool isFollowing;

  AuthorItem({
    required this.name,
    required this.followers,
    required this.image,
    required this.isFollowing,
  });
}