import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import 'screens/add_meal.dart';
import 'screens/homepage.dart';
import 'screens/diary.dart';
import 'screens/recipes.dart';
import 'screens/myinfo.dart';
import 'screens/auth_screen.dart';
import 'screens/register_info.dart';
import 'screens/main_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        child: const MyApp(),
        supportedLocales: const [Locale('en'), Locale('hu')],
        fallbackLocale: const Locale('hu'),
        path: "assets/translations"),
  );
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
      theme: ThemeData(
        fontFamily: GoogleFonts.roboto().fontFamily,
        primarySwatch: Colors.teal,
      ),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routes: {
        '/main_controller': (context) => MainController(),
        '/home': (context) => Homepage(),
        '/add_meal': (context) => AddMeal(),
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
