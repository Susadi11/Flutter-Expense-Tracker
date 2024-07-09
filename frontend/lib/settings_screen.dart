import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart'; // Import your ThemeNotifier class
import 'login.dart'; // Ensure Login screen is imported
import 'profile.dart'; // Ensure Profile screen is imported

class SettingsScreen extends StatelessWidget {
  final String username;
  final String email;

  const SettingsScreen({
    Key? key,
    required this.username,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Account Settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeNotifier.isDarkTheme,
            onChanged: (value) {
              themeNotifier.toggleTheme();
            },
          ),
          ListTile(
            title: const Text('My Profile'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile(username: username, email: email)),
              );
            },
          ),
        ],
      ),
    );
  }
}
