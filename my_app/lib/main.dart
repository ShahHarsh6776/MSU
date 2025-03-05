import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'service/auth_service.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url:
        'https://nemfdivhdchlasmalkff.supabase.co', // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lbWZkaXZoZGNobGFzbWFsa2ZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwMjQzMDYsImV4cCI6MjA1NjYwMDMwNn0.SOex4-2Yn7JuBBXHojdSH74aKYr2PuoC6pODvezj8_w', // Replace with your Supabase anon key
  ); /*

  // Initialize Supabase
  await Supabase.initialize(
    url:
        'https://hfdkhymtpqhbfvamcrjc.supabase.co', // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmZGtoeW10cHFoYmZ2YW1jcmpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwMTkzNjgsImV4cCI6MjA1NjU5NTM2OH0.LN2yIXsi5Aq2NGoXyEuDNdoFUufZ5jkEvo6YTb_mqAE', // Replace with your Supabase anon key
  );*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Supabase Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(), // Start with the LoginPage
    );
  }
}
