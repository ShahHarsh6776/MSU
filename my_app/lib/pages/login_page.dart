import 'package:flutter/material.dart';
import 'package:my_app/auth/auth_service.dart';
import 'package:my_app/pages/register_page.dart';
import 'package:my_app/pages/owner_dashboard.dart';
import 'package:my_app/pages/sponsor_dashboard_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception("Login failed. User not found.");
      }

      String role = "";
      String? userId;

      // Check if the user is an Owner
      final ownerCheck =
          await _supabase
              .from('owners')
              .select('owner_id')
              .eq('email', email)
              .maybeSingle();

      if (ownerCheck != null) {
        role = "Owner";
        userId = ownerCheck['owner_id'].toString();
      } else {
        // Check if the user is a Sponsor
        final sponsorCheck =
            await _supabase
                .from('sponsors')
                .select('id') // Use 'id' instead of 'sponsor_id'
                .eq('email', email)
                .maybeSingle();

        if (sponsorCheck != null) {
          role = "Sponsor";
          userId = sponsorCheck['id'].toString(); // Assign correct ID
        } else {
          throw Exception("User role not found.");
        }
      }

      // Store role in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role);

      if (mounted) {
        if (role == "Owner") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OwnerDashboardPage(ownerId: userId!),
            ),
          );
        } else if (role == "Sponsor") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SponsorDashboardPage(sponsorId: userId!),
            ),
          );
        } else {
          throw Exception("Invalid role.");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
