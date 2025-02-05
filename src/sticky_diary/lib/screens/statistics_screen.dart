import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../apiUrls.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String? _activeTheme;
  List<dynamic> _themes = [];
  String? _selectedThemeId;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
    fetchThemes();
  }

  Future<void> fetchThemes() async {
    final url = Uri.parse(ApiUrls.getThemesUrl);
    var token = await _storage.read(key: 'bearer');

    if (token == null) return;

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> themes = jsonDecode(response.body);
      setState(() {
        _themes = themes;
        var selectedTheme = themes.firstWhere(
          (theme) => theme['isSelected'] == true,
          orElse: () => null,
        );

        if (selectedTheme != null) {
          _activeTheme =  selectedTheme['primaryColor'] == "Default"
            ? "Default"
            : "${selectedTheme['primaryColor']}${selectedTheme['secondaryColor'] != null 
              ? ' & ${selectedTheme['secondaryColor']}' 
              : ''}";
          _selectedThemeId = selectedTheme['id'];
        }
      });
    }
  }

  Future<void> buyTheme(String themeId) async {
    final url = Uri.parse(ApiUrls.buyThemeUrl(themeId));
    var token = await _storage.read(key: 'bearer');

    if (token == null) return;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      fetchThemes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No enough points to buy this theme')),
      );
    }
  }

  Future<void> setThemeById(String themeId) async {
    final url = Uri.parse(ApiUrls.setThemeByIdUrl(themeId));
    var token = await _storage.read(key: 'bearer');

    if (token == null) return;

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      fetchThemes();
      fetchStatistics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to set theme')),
      );
    }
  }

  Future<void> fetchStatistics() async {
    final url = Uri.parse(ApiUrls.getUserStatisticsUrl);
    var token = await _storage.read(key: 'bearer');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not logged in')),
      );
      return;
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        final data = jsonDecode(response.body);

        _statistics = {
          "totalEntries": data["totalEntries"] ?? 0,
          "firstEntryDate": data["firstEntryDate"] ?? "",
          "lastEntryDate": data["lastEntryDate"] ?? "",
          "longestStreakDay": data["longestStreakDay"] ?? 0,
          "averageEntriesPerWeek": data["averageEntriesPerWeek"] ?? 0.0,
          "favoriteEntries": data["favoriteEntries"] ?? 0,
          "points": data["points"] ?? 0,
        };

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load statistics')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _statistics == null
              ? Center(
                  child: Text(
                    'No statistics available',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: theme.colorScheme.surface,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStatisticTile(
                                  'Total Entries',
                                  _statistics!['totalEntries'].toString(),
                                  Icons.book,
                                  theme),
                              _buildStatisticTile(
                                  'First Entry',
                                  _formatDate(_statistics!['firstEntryDate']),
                                  Icons.calendar_today,
                                  theme),
                              _buildStatisticTile(
                                  'Last Entry',
                                  _formatDate(_statistics!['lastEntryDate']),
                                  Icons.update,
                                  theme),
                              _buildStatisticTile(
                                  'Longest Streak',
                                  '${_statistics!['longestStreakDay']} days',
                                  Icons.bolt,
                                  theme),
                              _buildStatisticTile(
                                  'Avg Entries Per Week',
                                  _statistics!['averageEntriesPerWeek']
                                      .toStringAsFixed(2),
                                  Icons.bar_chart,
                                  theme),
                              _buildStatisticTile(
                                  'Favorite Entries',
                                  _statistics!['favoriteEntries'].toString(),
                                  Icons.favorite,
                                  theme),
                              _buildStatisticTile(
                                  'Points',
                                  _statistics!['points'].toString(),
                                  Icons.star,
                                  theme),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: theme.colorScheme.surface,
                        elevation: 5,
                        child: ListTile(
                          leading: const Icon(Icons.palette, color: Colors.purple),
                          title: const Text('Active theme'),
                          subtitle: Text(_activeTheme ?? 'Default'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildThemeList(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildThemeList(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: _themes.length,
        itemBuilder: (context, index) {
          var theme = _themes[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: theme['isSelected'] ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSecondary,
            elevation: 5,
            child: ListTile(
              leading: const Icon(Icons.palette, color: Colors.purple),
              title: Text(
                theme['primaryColor'] == 'Default' 
                  ? 'Default' 
                  : '${theme['primaryColor']} & ${theme['secondaryColor']}',
              ),
              subtitle: Text(theme['primaryColor'] == 'Default' 
                ? ''
                : theme['isBought'] ? 'Bought' : 'Not Bought'),
              trailing: theme['isSelected']
                  ? const Icon(Icons.check, color: Colors.white)
                  : ElevatedButton(
                      onPressed: theme['isBought']
                          ? () => setThemeById(theme['id'])
                          : () => buyTheme(theme['id']),
                      child: theme['isBought']
                          ? const Text('Select')
                          : const Text('Buy'),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticTile(
    String title, String value, IconData icon, ThemeData theme) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: Text(value, style: theme.textTheme.bodyMedium),
    );
  }

  String _formatDate(String dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "No data";
    }
    DateTime date = DateTime.parse(dateString);
    return DateFormat('yyyy-MM-dd').format(date);
  }
}