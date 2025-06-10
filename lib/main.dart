// ignore_for_file: use_super_parameters, avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
//import 'config/language_String.dart';
import 'config/light_and_dark.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Initialisation unique
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // ❌ Retirer cet appel inutile
    // Firebase.initializeApp().whenComplete(() {
    //   print("completed");
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ColorNotifier()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: const Locale('en', 'English'),
        theme: ThemeData(
          useMaterial3: false,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          dividerColor: Colors.transparent,
          fontFamily: 'SofiaProLight',
        ),
        home: const SplashScreen(), // ✅ Corrigé ici
      ),
    );
  }
}

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'enter_mail': 'Enter your email',
    },
    'ur_PK': {
      'enter_mail': 'اپنا ای میل درج کریں۔',
    }
  };
}
