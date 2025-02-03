import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../apiUrls.dart';

class EditEntryForm extends StatefulWidget {
  final String entryId;
  final String initialTitle;
  final String initialContent;
  final List<String> initialTags;

  const EditEntryForm({
    super.key,
    required this.entryId,
    required this.initialTitle,
    required this.initialContent,
    required this.initialTags,
  });

  @override
  State<EditEntryForm> createState() => _EditEntryFormState();
}

class _EditEntryFormState extends State<EditEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _contentController.text = widget.initialContent;
    _tagsController.text = widget.initialTags.join(', ');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      final title = _titleController.text;
      final content = _contentController.text;
      final tags = _tagsController.text.split(',').map((e) => e.trim()).toList();

      final url = Uri.parse(ApiUrls.editEntryByIdUrl(widget.entryId));
      var token = await _storage.read(key: 'bearer');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are not logged in')),
        );
        return;
      }

      final response = await http.put(
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

      // todo: fix update edit entry

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update entry')),
        );
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Entry')),
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
              const SizedBox(height: 16.0),
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
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Update Entry'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}