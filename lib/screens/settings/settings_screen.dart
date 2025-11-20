import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                ListTile(
                  title: Text('App Version'),
                  subtitle: Text('MMS beta 0.1'),
                ),
                Divider(height: 0),
                ListTile(
                  title: Text('Copyright'),
                  subtitle: Text('© November 2025'),
                ),
                Divider(height: 0),
                ListTile(
                  title: Text('About MMS'),
                  subtitle: Text(
                    'A messaging experience focused on privacy, speed, and real-time collaboration.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              onTap: _openLinkedIn,
              leading: const Icon(Icons.open_in_new),
              title: const Text('Connect on LinkedIn'),
              subtitle: const Text('linkedin.com/in/tiavinaram'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _openLinkedIn() async {
    const url = 'https://www.linkedin.com/in/tiavinaram/';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
