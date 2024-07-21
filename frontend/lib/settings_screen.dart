import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'login.dart'; // Ensure this import statement is added

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create an instance of ThemeNotifier using Provider.of
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
              // Navigate to Login screen
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
              themeNotifier.toggleTheme(); // Use instance method toggleTheme
            },
            activeColor: Color(0xFFC2AA81), // Set the active color to FFC2AA81
          ),
        ],
      ),
    );
  }
}
