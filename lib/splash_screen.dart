// ignore_for_file: camel_case_types, depend_on_referenced_packages, file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'All_Screen/bottom_navigation_bar_screen.dart';
import 'All_Screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isLogin;

  @override
  void initState() {
    super.initState();
    getDataFromLocal().then((value) {
      Timer(const Duration(seconds: 3), () {
        if (isLogin == true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Bottom_Navigation()),
                (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login_Screen()),
                (route) => false,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(
              image: AssetImage('assets/SplaseScreenImage.png'),
              height: 150,
              width: 150,
            ),
            Text(
              'ProZigzagBus',
              style: TextStyle(
                color: Color(0xff7D2AFF),
                fontSize: 25,
                fontFamily: 'SofiaProBold',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getDataFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = prefs.getBool("isLogin") ?? false;
    });
  }
}
