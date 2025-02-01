import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../apiUrls.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign up', style: Theme.of(context).textTheme.headlineMedium),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                controller: _emailTextController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                controller: _passwordTextController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ), 
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      },);
                    },  
                  ),  
                ),
                obscureText: _obscurePassword,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? null
                          : Theme.of(context).colorScheme.secondary;
                    }),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? null
                          : Theme.of(context).colorScheme.primary;
                    }),
                  ),
                  onPressed: _registerThenShowHomePageScreen,
                  child: Text(
                    'Sign up',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? null
                          : Theme.of(context).colorScheme.secondary;
                    }),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.disabled)
                          ? null
                          : Theme.of(context).colorScheme.primary;
                    }),
                  ),
                  onPressed: _loginThenShowHomePageScreen,
                  child: Text(
                    'Sign in',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerThenShowHomePageScreen() async {
    final url = Uri.parse(ApiUrls.registerUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": _emailTextController.text,
        "password": _passwordTextController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pushNamed('/home');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Failed'),
          content: Text(response.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loginThenShowHomePageScreen() async {
    final url = Uri.parse(ApiUrls.loginUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": _emailTextController.text,
        "password": _passwordTextController.text,
      }),
    );

    // todo: token

    if (response.statusCode == 200) {
      Navigator.of(context).pushNamed('/home');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(response.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}