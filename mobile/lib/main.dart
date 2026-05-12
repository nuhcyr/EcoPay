import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/home/home_page.dart';
import 'features/profile/profile_page.dart';
import 'features/rewards/rewards_page.dart';

void main() {
  runApp(const EcoPayApp());
}

class EcoPayApp extends StatelessWidget {
  const EcoPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoPay Mobile',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppCoordinator(),
    );
  }
}

enum AuthView { login, register }

class AppCoordinator extends StatefulWidget {
  const AppCoordinator({super.key});

  @override
  State<AppCoordinator> createState() => _AppCoordinatorState();
}

class _AppCoordinatorState extends State<AppCoordinator> {
  bool _isAuthenticated = false;
  AuthView _authView = AuthView.login;
  int _sessionKey = 0;

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      if (_authView == AuthView.login) {
        return LoginPage(
          key: ValueKey('login_$_sessionKey'),
          onLoginSuccess: () => setState(() => _isAuthenticated = true),
          onRegisterTap: () => setState(() => _authView = AuthView.register),
        );
      }
      return RegisterPage(
        key: ValueKey('register_$_sessionKey'),
        onRegisterSuccess: () => setState(() {
          _isAuthenticated = true;
          _authView = AuthView.login;
        }),
        onBackToLogin: () => setState(() => _authView = AuthView.login),
      );
    }
    return HomeShell(
      key: ValueKey('home_$_sessionKey'),
      onLogoutTap: () => setState(() {
        _sessionKey++;
        _isAuthenticated = false;
        _authView = AuthView.login;
      }),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.onLogoutTap});

  final VoidCallback onLogoutTap;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const RewardsPage(),
      ProfilePage(onLogoutTap: widget.onLogoutTap),
    ];

    final titles = ['EcoPay', 'Eco Rewards', 'Profile'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_currentIndex])),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) => setState(() => _currentIndex = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'Rewards'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
