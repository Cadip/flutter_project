import 'package:flutter/material.dart';
import 'note_page.dart';
import 'profile_page.dart';

class MainNavigation extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? currentThemeMode;

  const MainNavigation({super.key, this.onToggleTheme, this.currentThemeMode});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NotePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: widget.currentThemeMode == ThemeMode.dark ? Color(0xFF303030) : Colors.white,
        foregroundColor: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
        elevation: 1,
        shadowColor: widget.currentThemeMode == ThemeMode.dark ? Colors.black54 : Colors.black26,
        actions: [
          IconButton(
            icon: Icon(
              widget.currentThemeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              color: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: widget.currentThemeMode == ThemeMode.dark ? Colors.white : Colors.black,
        unselectedItemColor: widget.currentThemeMode == ThemeMode.dark ? Colors.white70 : Colors.black54,
        backgroundColor: widget.currentThemeMode == ThemeMode.dark ? Color(0xFF202020) : Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Notes',),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
