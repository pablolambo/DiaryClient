import 'package:Diary/firebase_options.dart';
import 'package:Diary/navigator_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'models/push_notification.dart';
import 'screens/entries_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _messageStreamController = BehaviorSubject<RemoteMessage>();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await flutterLocalNotificationsPlugin.initialize(settings);
  }


Future<void> main(context) async {
  WidgetsFlutterBinding.ensureInitialized();
  final logger = Logger();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true,
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    sound: true,
  );

  await _setupLocalNotifications();

  runApp(DiaryApp());
}


class DiaryApp extends StatefulWidget {
  DiaryApp({super.key});

  @override
  State<DiaryApp> createState() => _DiaryAppState();
}

class _DiaryAppState extends State<DiaryApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

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
          '/': (context) => const SignUpScreen(),
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

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', 'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      platformDetails,
    );
  }
}