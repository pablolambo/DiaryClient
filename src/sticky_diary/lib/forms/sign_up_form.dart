import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../apiUrls.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  bool _obscurePassword = true;
  final storage = const FlutterSecureStorage();

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
                  onPressed: _registerThenShowLoginScreen,
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
                  onPressed: _showLoginScreen,
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

  void _showLoginScreen() {
    Navigator.of(context).pushNamed('/login');
  }

  Future<void> _registerThenShowLoginScreen() async {
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
        // final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);

        // final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        // if (apnsToken != null) {
        //   // APNS token is available, make FCM plugin API requests...
        // }

        // final fcmToken = await FirebaseMessaging.instance.getToken(); 
        // 1. "cuosDJCOQz6R1He9teB60y:APA91bEI0E-MWmSy-3NyaA-5ULi03VOprzFGki04Mr0utwCycTr7l2vN7x5DM-dgy-ELmku-Pq7I1wvA1ZUOUZTQmi2MymHWooLTAPUV3jSAABN-Y-p4VrQ"
        // 2. "cuosDJCOQz6R1He9teB60y:APA91bEI0E-MWmSy-3NyaA-5ULi03VOprzFGki04Mr0utwCycTr7l2vN7x5DM-dgy-ELmku-Pq7I1wvA1ZUOUZTQmi2MymHWooLTAPUV3jSAABN-Y-p4VrQ"
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered'),),
        );

      Navigator.of(context).pushNamed('/login');
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
}