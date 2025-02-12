import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../apiUrls.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  bool _obscurePassword = true;
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sign in', style: Theme.of(context).textTheme.headlineMedium),
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
        ),
      ),
    );
  }

  Future<void> _loginThenShowHomePageScreen() async {
    final url = Uri.parse(ApiUrls.loginUrl);

    //_emailTextController.text = 'pawelspam42@gmail.com';
    //_passwordTextController.text = 'Uniwersal11#';

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": _emailTextController.text,
        "password": _passwordTextController.text,
      }),
    );

    final responseBody = jsonDecode(response.body);

    bool inactive = await hasBeenInactiveFor7Days();

    if (response.statusCode == 200) {
      final String token = responseBody['accessToken'];

      if (token.isNotEmpty) {
        await storage.write(key: 'bearer', value: token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_login', DateTime.now().millisecondsSinceEpoch);
      }

      Navigator.of(context).pushNamed('/home');

      if (inactive) {
        _showInactiveRewardDialog();
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(responseBody),
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

  Future<bool> hasBeenInactiveFor7Days() async {
    // final prefs = await SharedPreferences.getInstance();
    // final lastLogin = prefs.getInt('last_login') ?? 0;

    // if (lastLogin == 0) {
    //   return true;
    // }

    // final lastLoginDate = DateTime.fromMillisecondsSinceEpoch(lastLogin);
    // final difference = DateTime.now().difference(lastLoginDate).inDays;

    // return difference >= 7;

    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getInt('last_login') ?? 0;

    if (lastLogin == 0) {
      return true;
    }

    final lastLoginDate = DateTime.fromMillisecondsSinceEpoch(lastLogin);
    final difference = DateTime.now().difference(lastLoginDate).inSeconds;

    return difference >= 15;
  }

  void _showInactiveRewardDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('👏 Welcome Back!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.emoji_events, color: Colors.green, size: 50),
              SizedBox(height: 10),
              Text(
                'You haven’t logged in for 7 days, but you’re back! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'As a reward for staying on track, you earned 50 points! 🏆',
                textAlign: TextAlign.center,
              ),
            ],
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
}