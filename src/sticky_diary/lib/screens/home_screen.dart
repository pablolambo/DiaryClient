import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../apiUrls.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> _entries = [];
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Entries'),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _entries.isEmpty
          ? const Center(child: Text('Create your first entry'))
          : ListView.builder(
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entry = _entries[index];
              bool isFavourite = entry['isFavourite'] ?? false;
              List<String> tags = List<String>.from(
                (entry['entryTags'] as List).map<String>((tag) => (tag as Map<String, dynamic>)['name'] ?? '')
              );
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  title: Text(
                    entry['title'].length > 32
                        ? '${entry['title'].substring(0, 32)}...'
                        : entry['title'],
                    style: theme.textTheme.titleLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['content'].length > 100
                            ? '${entry['content'].substring(0, 100)}...'
                            : entry['content'],
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('yyyy-MM-dd').format(DateTime.parse(entry['date'])),
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: tags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(tag),
                            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isFavourite ? Icons.star : Icons.star_border,
                      color: isFavourite ? theme.colorScheme.primary : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        entry['isFavourite'] = !isFavourite;
                      });
                    },
                  ),
                ),
              );
            },
          ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              tooltip: 'Rewards',
              icon: Icon(Icons.emoji_events, 
                color: _selectedIndex == 0 ? theme.colorScheme.primary : Colors.grey),
              onPressed: () => _onItemTapped(0),
            ),
            const SizedBox(width: 40),
            IconButton(
              tooltip: 'Statistics',
              icon: Icon(Icons.bar_chart, 
                color: _selectedIndex == 1 ? theme.colorScheme.primary : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        tooltip: 'Add Entry',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

   Future<void> _fetchEntries() async {
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));

    final url = Uri.parse(ApiUrls.searchEntriesUrl);
    var token = await _storage.read(key: 'bearer');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not logged in')),
      );
      return;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "from": DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").format(oneYearAgo),
        "to": DateFormat("yyyy-MM-ddTHH:mm:ss.SSS'Z'").format(now),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _entries = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load entries')),
      );
    }
  }
}