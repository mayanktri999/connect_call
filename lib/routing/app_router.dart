import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/calls/call_history_screen.dart';
import '../screens/contacts/contacts_screen.dart';

import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
// Import your existing auth screens
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
       path: '/calls',
        name: 'calls',
        builder: (context, state) => const CallHistoryScreen(),
          ),

    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/contacts',
      name: 'contacts',
      builder: (context, state) => const ContactsScreen(),
    ),
  ],
);