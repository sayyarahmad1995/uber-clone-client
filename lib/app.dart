import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'theme.dart';
import 'rider/rider_home_page.dart';

class HiGoApp extends StatelessWidget {
  const HiGoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'HiGO Rides',
    debugShowCheckedModeBanner: false,
    theme: hiGoTheme,
    routes: {
      '/': (_) => const HomePage(),
      '/login': (_) => const LoginPage(),
      '/register': (_) => const RegisterPage(),
      '/rider': (_) => const RiderHomePage(),
    },
  );
}
