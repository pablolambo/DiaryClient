import 'package:Diary/firebase_options.dart';
import 'package:Diary/navigator_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'models/push_notification.dart';
import 'screens/entries_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:logger/logger.dart';

final _messageStreamController = BehaviorSubject<RemoteMessage>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();

  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    PushNotification notification = PushNotification(
      title: initialMessage.notification?.title ?? 'Write your entry for today!',
      body: initialMessage.notification?.body ?? 'keep a good habit.',
      dataTitle: initialMessage.data['title'] ?? 'Write your entry for today!',
      dataBody: initialMessage.data['body'] ?? 'keep a good habit.',
    );
  }

  logger.d("Handling a background message: ${message.messageId}, $message");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);

  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
  }

  final fcmToken = await FirebaseMessaging.instance.getToken(); 

  // https://cdn-icons-png.freepik.com/256/9812/9812548.png
  streamForegroundMessageHandlerController(logger);

  runApp(const DiaryApp());
}

void streamForegroundMessageHandlerController(Logger logger) {
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      logger.d('Handling a foreground message: ${message.messageId}');
      logger.d('Message data: ${message.data}');
      logger.d('Message notification: ${message.notification?.title}');
      logger.d('Message notification: ${message.notification?.body}');
    }
    
    _messageStreamController.sink.add(message);
  });
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sticky diary',
        navigatorObservers: [
          AppNavigatorObserver(onPop: () {
            _onAddEntryFormPop(context);
          })
        ],
        routes: {
          '/': (context) => const SignUpScreen(),//SignUpScreen(),
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const SignUpScreen(),
          '/login': (context) => const SignInScreen(),
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
            bodyLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            displaySmall: TextStyle(
              fontSize: 12,
            ), 
          ),
        ),
    );
  }

  void _onAddEntryFormPop(BuildContext context) {
    if (Navigator.canPop(context)) {
      final entriesScreenState = context.findAncestorStateOfType<EntriesScreenState>();
      entriesScreenState?.fetchEntries();
    }
  }
}

// class _MyHomePageState extends State<MyHomePage> {
//   String _lastMessage = "";

//   @override
//   void initState() {
//     super.initState();
//     _messageStreamController.listen((message) {
//       setState(() {
//         if (message.notification != null) {
//           _lastMessage = 'Received a notification message:'
//               '\nTitle=${message.notification?.title},'
//               '\nBody=${message.notification?.body},'
//               '\nData=${message.data}';
//         } else {
//           _lastMessage = 'Received a data message: ${message.data}';
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sticky diary'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Last message from Firebase Messaging:',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             Text(
//               _lastMessage,
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
