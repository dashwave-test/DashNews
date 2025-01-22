import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../profile/edit_profile_screen.dart';

class NewsSourcesScreen extends StatefulWidget {
  static const routeName = '/news-sources';

  const NewsSourcesScreen({Key? key}) : super(key: key);

  @override
  _NewsSourcesScreenState createState() => _NewsSourcesScreenState();
}

class _NewsSourcesScreenState extends State<NewsSourcesScreen> {
  final List<Map<String, String>> sources = [
    {'name': 'Reuters', 'logo': 'assets/images/reuters.png'},
    {'name': 'Associated Press', 'logo': 'assets/images/ap.png'},
    {'name': 'BBC News', 'logo': 'assets/images/bbc.png'},
    {'name': 'CNN', 'logo': 'assets/images/cnn.png'},
    {'name': 'The Guardian', 'logo': 'assets/images/guardian.png'},
    {'name': 'Al Jazeera', 'logo': 'assets/images/aljazeera.png'},
    {'name': 'Bloomberg', 'logo': 'assets/images/bloomberg.png'},
    {'name': 'CNBC', 'logo': 'assets/images/cnbc.png'},
  ];

  Set<String> selectedSources = {};
  bool _isLoading = false;

  Future<void> _saveSources() async {
    if (selectedSources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one news source'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'followedSources': selectedSources.toList()});

        if (mounted) {
          Navigator.of(context).pushReplacementNamed(EditProfileScreen.routeName);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving news sources: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'News Sources',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your preferred news sources',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: sources.length,
                  itemBuilder: (context, index) {
                    final source = sources[index];
                    final isSelected = selectedSources.contains(source['name']);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedSources.remove(source['name']);
                          } else {
                            selectedSources.add(source['name']!);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.asset(
                                source['logo']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              source['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSources,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                          'Continue',
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
      ),
    );
  }
}