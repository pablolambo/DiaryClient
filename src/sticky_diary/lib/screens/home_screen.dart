import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../apiUrls.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../forms/add_entry_form.dart';

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
                (entry['entryTags'] as List?)?.map<String>((tag) => (tag as Map<String, dynamic>)['name'] ?? '') ?? []
              );
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  minVerticalPadding: 20,
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
                        entry['content'].length > 150
                            ? '${entry['content'].substring(0, 150)}...'
                            : entry['content'],
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('yyyy-MM-dd').format(DateTime.parse(entry['date'])),
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 8),
                     Wrap(
                      spacing: 1,
                      runSpacing: 1, 
                      children: [
                        ...tags.take(3).map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(tag.length > 20 ? '${tag.substring(0, 20)}...' : tag),
                            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                          ),
                        )),
                        if (tags.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Chip(
                              label: Text('...'),
                              backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                            ),
                          ),
                      ],
                    ),
                    ],
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavourite ? Icons.star : Icons.star_border,
                          color: isFavourite ? theme.colorScheme.primary : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            entry['isFavourite'] = !isFavourite;
                          });
                          _setFavouriteStatus(entry['id'], !isFavourite);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(entry['id']),
                      ),
                    ],
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEntryForm()),
          );
        },
        tooltip: 'Add Entry',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<void> _setFavouriteStatus(String entryId, bool isFavourite) async {
    final url = Uri.parse(ApiUrls.setEntryAsFavouriteByIdUrl(entryId));
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
        'isFavourite': isFavourite,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isFavourite ? 'Marked as Favourite' : 'Unmarked as Favourite')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favourite status')),
      );
    }
  }

  Future<void> _fetchEntries() async {
    var platform = ApiUrls.getCurrentPlatform();
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

  void _confirmDelete(String entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEntry(entryId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  Future<void> _deleteEntry(String entryId) async {
    final url = Uri.parse(ApiUrls.deleteEntryByIdUrl(entryId));
    var token = await _storage.read(key: 'bearer');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not logged in')),
      );
      return;
    }

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      setState(() {
        _entries.removeWhere((entry) => entry['id'] == entryId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete entry')),
      );
    }
  }
}