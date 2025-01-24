import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';

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

  bool _isLoading = false;

  List<NewsSource> get _filteredSources => _searchQuery.isEmpty
      ? _sources
      : _sources
          .where((source) =>
              source.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  Future<void> _handleNextPress() async {
    if (_followedSources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one news source'),
          backgroundColor: Color(0xFF246BFD),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the current user
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Add the followed sources to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'followedSources': _followedSources.toList(),
          }, SetOptions(merge: true));

          if (mounted) {
            Navigator.pushReplacementNamed(context, EditProfileScreen.routeName);
          }
        } else {
          throw Exception('No user logged in');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFollowSource(String sourceName) async {
    setState(() {
      if (_followedSources.contains(sourceName)) {
        _followedSources.remove(sourceName);
      } else {
        _followedSources.add(sourceName);
      }
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'followedSources': _followedSources.toList(),
        }, SetOptions(merge: true));
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating sources: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 16,
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
                      const SizedBox(height: 4),
                      Text(
                        source.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: ElevatedButton(
                          onPressed: () => _toggleFollowSource(source.name),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? Colors.white
                                : const Color(0xFF246BFD),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(
                                color: isFollowing
                                    ? const Color(0xFFEEEEEE)
                                    : const Color(0xFF246BFD),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isFollowing ? 'Following' : 'Follow',
                            style: TextStyle(
                              fontSize: 10,
                              color: isFollowing
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNextPress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _followedSources.isEmpty || _isLoading
                      ? const Color(0xFF246BFD).withOpacity(0.5)
                      : const Color(0xFF246BFD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsSource {
  final String name;
  final String logo;

  NewsSource({required this.name, required this.logo});
}