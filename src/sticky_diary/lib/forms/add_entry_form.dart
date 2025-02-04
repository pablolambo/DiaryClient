import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../apiUrls.dart';

class AddEntryForm extends StatefulWidget {
  final VoidCallback onFormClosed;

  const AddEntryForm({super.key, required this.onFormClosed});


  @override
  State<AddEntryForm> createState() => _AddEntryFormState();
}

class _AddEntryFormState extends State<AddEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      final title = _titleController.text;
      final content = _contentController.text;
      final tags = _tagsController.text.split(',').map((e) => e.trim()).toList();

      final url = Uri.parse(ApiUrls.createEntryUrl);
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
          'title': title,
          'content': content,
          'tagNames': tags,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);

        List<dynamic> badges = responseData['badgesAwarded'] ?? [];

        widget.onFormClosed();
        Navigator.pop(context);
        if (badges.isNotEmpty) {
          _showBadgeAwardedDialog(badges);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry created successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create entry')),
        );
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showBadgeAwardedDialog(List<dynamic> badges) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('🎉 Badge earned!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: badges.map((badge) {
              return ListTile(
                leading: const Icon(Icons.star, color: Colors.amber, size: 40),
                title: Text(
                  badge['name'] ?? 'Unnamed badge',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Earned for ${badge['value']} entries!'),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create new entry'),),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0,),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                minLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0,),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Create Entry'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
