import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/add_food.dart';
import 'screens/homepage.dart';
import 'screens/diary.dart';
import 'screens/recipes.dart';
import 'screens/myinfo.dart';
import 'screens/auth_screen.dart';
import 'screens/register_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => Homepage(),
        '/add_food': (context) => AddFood(),
        '/diary': (context) => Diary(),
        '/recipes': (context) => Recipes(),
        '/myinfo': (context) => Myinfo(),
        '/register_info': (context) => RegisterInfo(),
        '/auth_screen': (context) => AuthScreen(),
      },
      home: AuthScreen(),
    );
  }
}
