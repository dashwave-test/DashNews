import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/edit_profile_screen.dart';
import '../services/shared_preferences_manager.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  String getInitials(String fullName) {
    List<String> names = fullName.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for(int i = 0; i < numWords; i++) {
      initials += names[i][0].toUpperCase();
    }
    return initials;
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await SharedPreferencesManager.clearAll();
    await authProvider.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final userData = snapshot.data?.data() as Map<String, dynamic>?;
              final String fullName = userData?['fullName'] ?? 'User Name';
              final String? profilePicture = userData?['profilePicture'] as String?;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (profilePicture != null && profilePicture.isNotEmpty)
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(profilePicture),
                      )
                    else
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          getInitials(fullName),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user?.email ?? 'user@example.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      currentUsername: user?.displayName ?? '',
                      currentFullName: user?.displayName ?? '',
                      currentEmail: user?.email ?? '',
                      currentPhoneNumber: '',
                    ),
                  ),
                );
              },
              child: Text('Edit Profile'),
            ),
          ),
          Divider(),
          // Rest of the settings options
          /*ListTile(
            leading: Icon(Icons.person),
            title: Text('Account'),
            onTap: () {
              // Navigate to account settings
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy'),
            onTap: () {
              // Navigate to privacy settings
            },
          ),*/
          ListTile(
            leading: Icon(Icons.policy),
            title: Text('Privacy Policy'),
            onTap: () {
              _launchURL('https://studio.dashwave.io/privacy-policy');
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Terms and Conditions'),
            onTap: () {
              _launchURL('https://studio.dashwave.io/terms-and-conditions');
            },
          ),
          /*ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            onTap: () {
              // Navigate to help and support
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              // Navigate to about page
            },
          ),*/
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}