import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Box _authBox = Hive.box('authBox');

  // sign in
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session != null) {
        await _cacheSession(response.session!);
      }
      return response;
    } catch (e) {
      // Handle network or other errors gracefully
      print('Sign in error: $e');
      // Return a failed AuthResponse or handle accordingly
      rethrow;
    }
  }

  // sign up
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.session != null) {
        await _cacheSession(response.session!);
      }
      return response;
    } catch (e) {
      // Handle network or other errors gracefully
      print('Sign up error: $e');
      // Return a failed AuthResponse or handle accordingly
      rethrow;
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      // Handle offline or network error gracefully
    }
    await _authBox.clear();
  }

  // cache session locally
  Future<void> _cacheSession(Session session) async {
    await _authBox.put('accessToken', session.accessToken);
    await _authBox.put('refreshToken', session.refreshToken);
    await _authBox.put('userId', session.user.id);
    await _authBox.put('userEmail', session.user.email);
    await _authBox.put('userName', session.user.userMetadata?['name']);
  }

  // get cached session info
  String? getCachedUserId() => _authBox.get('userId');
  String? getCachedUserEmail() => _authBox.get('userEmail');
  String? getCachedUserName() => _authBox.get('userName');

  // get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email ?? getCachedUserEmail();
  }

  // get user name
  String? getCurrentUserName() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.userMetadata?['name'] ?? getCachedUserName();
  }

  // get user id
  String? getCurrentUserId() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.id ?? getCachedUserId();
  }
}
