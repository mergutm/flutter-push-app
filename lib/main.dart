import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// handler para mensajes en segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // print("mensaje en segundo plano: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // handler para mensajes en segundo plano
  // Los mensajes en segundo plano son aquellos que se reciben cuando la app está
  // cerrada o en segundo plano
  // Si no se define un handler, los mensajes se pierden
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push App',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Página Principal de Flutter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _logController = TextEditingController();

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  void _log(String message) {
    // print(message);
    _logController.text += "$message\n";
  }

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
  }

  Future<void> _setupPushNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _log('El usuario concedió permiso: ${settings.authorizationStatus}');

      String? token = await messaging.getToken();
      _log("Token FCM: $token");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _log('¡Se recibió un mensaje en primer plano!');
        _log('Datos del mensaje: ${message.data}');

        if (message.notification != null) {
          _log('Título de la Notificación: ${message.notification?.title}');
          _log('Cuerpo de la Notificación: ${message.notification?.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${message.notification?.title ?? 'Notificación'}: ${message.notification?.body ?? ''}',
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    } catch (e) {
      _log("Error al configurar notificaciones: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    //

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _logController,
                  maxLines: null,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Registros',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
