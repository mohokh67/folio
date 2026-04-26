import 'package:flutter/material.dart';
import 'categories_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            subtitle: const Text('Add, edit, or remove categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
