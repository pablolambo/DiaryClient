import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/sign_up_screen.dart';


void main() => runApp(const DiaryApp());
class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sticky diary',
        routes: {
          '/': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const SignUpScreen(),
        },
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,  
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              fontSize: 30,
              fontStyle: FontStyle.italic,
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            displaySmall: TextStyle(
              fontSize: 12,
            ), 
          ),
        ),
    );
  }
}