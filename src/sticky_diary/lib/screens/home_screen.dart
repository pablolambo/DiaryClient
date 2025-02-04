import 'package:Diary/screens/badges_screen.dart';
import 'package:flutter/material.dart';
import '../forms/add_entry_form.dart';
import 'entries_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const BadgesScreen(),
    const EntriesScreen(),
    const StatisticsScreen(),
  ];
  final List<String> titles = ['Badges', 'Entries', 'Statistics'];


  @override
  void initState() {
    super.initState();
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
        title: Text(titles[_selectedIndex]),
      ),
      body: _screens[_selectedIndex],
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
              tooltip: 'Entries',
              icon: Icon(Icons.book, 
                color: _selectedIndex == 1 ? theme.colorScheme.primary : Colors.grey),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 40),
            IconButton(
              tooltip: 'Statistics',
              icon: Icon(Icons.bar_chart, 
                color: _selectedIndex == 2 ? theme.colorScheme.primary : Colors.grey),
              onPressed: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEntryForm(
                onFormClosed: () {
                  final entriesScreenState = context.findAncestorStateOfType<EntriesScreenState>();
                  entriesScreenState?.fetchEntries();
                },
              ),
              settings: const RouteSettings(name: 'add_entry'),  
            ),
          );
        },
        tooltip: 'Add Entry',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}