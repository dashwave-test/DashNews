import 'package:flutter/material.dart';
import 'profile_screen.dart';

class NewsSourcesScreen extends StatefulWidget {
  static const routeName = '/news-sources';

  const NewsSourcesScreen({super.key});

  @override
  State<NewsSourcesScreen> createState() => _NewsSourcesScreenState();
}

class _NewsSourcesScreenState extends State<NewsSourcesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _followedSources = {};
  final List<NewsSource> _sources = [
    NewsSource(name: 'CNBC', logo: 'assets/images/cnbc.png'),
    NewsSource(name: 'VICE', logo: 'assets/images/vice.png'),
    NewsSource(name: 'Vox', logo: 'assets/images/vox.png'),
    NewsSource(name: 'BBC News', logo: 'assets/images/bbc.png'),
    NewsSource(name: 'SCMP', logo: 'assets/images/scmp.png'),
    NewsSource(name: 'CNN', logo: 'assets/images/cnn.png'),
    NewsSource(name: 'MSN', logo: 'assets/images/msn.png'),
    NewsSource(name: 'CNET', logo: 'assets/images/cnet.png'),
    NewsSource(name: 'USA Today', logo: 'assets/images/usa_today.png'),
    NewsSource(name: 'TIME', logo: 'assets/images/time.png'),
    NewsSource(name: 'Buzzfeed', logo: 'assets/images/buzzfeed.png'),
    NewsSource(name: 'Daily Mail', logo: 'assets/images/daily_mail.png'),
  ];

  List<NewsSource> get _filteredSources => _searchQuery.isEmpty
      ? _sources
      : _sources
          .where((source) =>
              source.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Choose your News Sources',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF246BFD)),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
              ),
              itemCount: _filteredSources.length,
              itemBuilder: (context, index) {
                final source = _filteredSources[index];
                final isFollowing = _followedSources.contains(source.name);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          source.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      source.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (isFollowing) {
                              _followedSources.remove(source.name);
                            } else {
                              _followedSources.add(source.name);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing
                              ? const Color(0xFF246BFD)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(
                              color: isFollowing
                                  ? const Color(0xFF246BFD)
                                  : const Color(0xFFEEEEEE),
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isFollowing ? 'Following' : 'Follow',
                          style: TextStyle(
                            fontSize: 12,
                            color: isFollowing
                                ? Colors.white
                                : const Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_followedSources.isNotEmpty) {
                    Navigator.pushReplacementNamed(
                        context, ProfileScreen.routeName);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF246BFD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsSource {
  final String name;
  final String logo;

  NewsSource({required this.name, required this.logo});
}