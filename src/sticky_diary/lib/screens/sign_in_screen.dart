import 'package:flutter/material.dart';
import '../forms/sign_in_form.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SizedBox(
          child: Card(
            child: SignInForm(),
          ),
        ),
      ),
    );
  }
}