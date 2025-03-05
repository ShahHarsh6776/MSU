import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign up with email, password, and username
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String phone, // Add phone parameter
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        throw Exception('Sign-up failed: User is null');
      }

      // Insert user data into the profiles table
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
        'email': email,
        'phone_number': phone, // Add phone number
      });
    } catch (e) {
      throw Exception('Sign-up error: $e');
    }
  }

  // Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign-in failed: User is null');
      }
    } catch (e) {
      throw Exception('Sign-in error: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
}
