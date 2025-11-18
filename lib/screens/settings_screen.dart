import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('About Sorted Pics'),
            subtitle: const Text('Version 1.0.0'),
            leading: const Icon(Icons.info),
          ),
          ListTile(
            title: const Text('Clear All Data'),
            leading: const Icon(Icons.delete_forever),
            onTap: () {
              // Implement clear data logic if needed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not implemented in this demo')),
              );
            },
          ),
        ],
      ),
    );
  }
}
