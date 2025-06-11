import 'package:flutter/material.dart';
import '/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/main_navigation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthGate extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? currentThemeMode;

  const AuthGate({super.key, this.onToggleTheme, this.currentThemeMode});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isOnline = true;
  bool _hasCachedSession = false;
  final Box _authBox = Hive.box('authBox');

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _checkCachedSession();
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult != ConnectivityResult.none;
    });
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  void _checkCachedSession() {
    final userId = _authBox.get('userId');
    setState(() {
      _hasCachedSession = userId != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session != null) {
          return MainNavigation(
            onToggleTheme: widget.onToggleTheme,
            currentThemeMode: widget.currentThemeMode,
          );
        } else if (!_isOnline && _hasCachedSession) {
          // Offline but cached session exists
          return MainNavigation(
            onToggleTheme: widget.onToggleTheme,
            currentThemeMode: widget.currentThemeMode,
          );
        } else if (!_isOnline && !_hasCachedSession) {
          // Offline and no cached session
          return Scaffold(
            body: Center(
              child: Text(
                'No internet connection and no cached session available.',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          return LoginPage();
        }
      },
    );
  }
}
