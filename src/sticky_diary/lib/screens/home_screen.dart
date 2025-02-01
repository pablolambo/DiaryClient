import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});
  
  @override
  Widget build(context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}