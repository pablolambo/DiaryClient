import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../apiUrls.dart';
import '../forms/edit_entry_form.dart';

class EntriesScreen extends StatefulWidget {

  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => EntriesScreenState();

  // @override
  // EntriesScreenState createState() => EntriesScreenState();

}

class EntriesScreenState extends State<EntriesScreen> {
  List<dynamic> _entries = [];
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
                      spacing: 2.5,
                      runSpacing: 5,
                      children: [
                        ...tags.map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(tag.length > 20 ? '${tag.substring(0, 20)}...' : tag),
                            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                          ),
                        )),
                      ],
                    ),
                    ],
                  ),
                  trailing: Wrap(
                    alignment: WrapAlignment.start,
                    children: [ IconButton(
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
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        bool? updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditEntryForm(
                              entryId: entry['id'],
                              initialTitle: entry['title'],
                              initialContent: entry['content'],
                              initialTags: tags,
                            ),
                          ),
                        );
                        if (updated == true) {
                          fetchEntries();
                        }
                      },
                    ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Future<void> fetchEntries() async {
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
        title: const Text('Delete',  style: TextStyle(color: Colors.red),),
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
        fetchEntries();
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
}