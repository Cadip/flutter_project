import 'package:flutter/material.dart';
import '/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'notes/note.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANONKEY']!,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notesBox');
  await Hive.openBox('settingsBox');
  await Hive.openBox('authBox');

  final box = Hive.box<Note>('notesBox');
  print('Hive notesBox contains ${box.length} notes on app start.');

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late ThemeMode _themeMode;
  final settingsBox = Hive.box('settingsBox');

  @override
  void initState() {
    super.initState();
    final savedTheme = settingsBox.get('themeMode', defaultValue: 'light');
    print('Theme loaded on startup: $savedTheme');
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        settingsBox.put('themeMode', 'dark');
        print('Theme changed to dark');
      } else {
        _themeMode = ThemeMode.light;
        settingsBox.put('themeMode', 'light');
        print('Theme changed to light');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Diary',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          shadowColor: Colors.black26,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF202020),
        primaryColor: Color(0xFF303030),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF303030),
          foregroundColor: Colors.white,
          elevation: 1,
          shadowColor: Colors.black54,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF505050),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
        ),
      ),
      themeMode: _themeMode,
      home: AuthGate(
        onToggleTheme: toggleTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}
