import 'package:amazonclone/providers/auth_provider.dart';
import 'package:amazonclone/providers/cart_provider.dart';
import 'package:amazonclone/screens/auth_screen.dart';
import 'package:amazonclone/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Firebase Auth Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ?  MainScreen() : const AuthScreen();
          },
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}
