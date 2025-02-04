import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../apiUrls.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  _BadgesScreenState createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _allBadges = [];
  Set<String> _unlockedBadgeIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBadges();
  }

  Future<void> fetchBadges() async {
    var token = await _storage.read(key: 'bearer');
    if (token == null) return;

    final userResponse = await http.get(
      Uri.parse(ApiUrls.getUserInfoUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    final badgesResponse = await http.get(
      Uri.parse(ApiUrls.getBadgesUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (userResponse.statusCode == 200 && badgesResponse.statusCode == 200) {
      final userData = jsonDecode(userResponse.body);
      final allBadges = jsonDecode(badgesResponse.body);

      setState(() {
        _allBadges = allBadges;
        _unlockedBadgeIds = {
          for (var badge in userData['unlockedBadges']) badge['id']
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Earn badges & unlock new themes!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Every badge you earn grants you 500 points. Use your points to unlock new themes and personalize your diary experience!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allBadges.length,
                      itemBuilder: (context, index) {
                        final badge = _allBadges[index];
                        final isUnlocked = _unlockedBadgeIds.contains(badge['id']);
                        return Card(
                          color: isUnlocked ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSecondary,
                          child: ListTile(
                            leading: Icon(Icons.star,
                                color: isUnlocked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.inversePrimary),
                            title: Text(badge['name']),
                            subtitle: Text(
                              badge['name'].toLowerCase().contains('streak') 
                                ? 'Write an entry ${badge['value']} days in a row.' 
                                : 'Total of ${badge['value']} entries created.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}