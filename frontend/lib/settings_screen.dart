import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create an instance of ThemeNotifier using Provider.of
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Account Settings'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Add navigation to account settings screen
            },
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: themeNotifier.isDarkTheme,
            onChanged: (value) {
              themeNotifier.toggleTheme(); // Use instance method toggleTheme
            },
          ),
          /*SwitchListTile(
            title: Text('Enable Notifications'),
            value: themeNotifier.notificationsEnabled,
            onChanged: (value) {
              themeNotifier.toggleNotifications(value); // Use instance method toggleNotifications
            },
          ),*/
        ],
      ),
    );
  }
}
