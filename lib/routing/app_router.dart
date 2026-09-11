import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/call_model.dart' as call_model;
import '../models/user_model.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/calls/audio_call_screen.dart';
import '../screens/calls/call_history_screen.dart';
import '../screens/calls/incoming_call_screen.dart';
import '../screens/calls/video_call_screen.dart';
import '../screens/contacts/contacts_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final isSplash = state.matchedLocation == '/splash';

    final isLogin = state.matchedLocation == '/login';

    final isRegister = state.matchedLocation == '/register';

    // Logged-out users can access auth screens.
    if (user == null) {
      if (isSplash || isLogin || isRegister) {
        return null;
      }

      return '/login';
    }

    // Logged-in users should not return to auth screens.
    if (isLogin || isRegister) {
      return '/home';
    }

    return null;
  },

  routes: [
    // --------------------------------------------------
    // SPLASH
    // --------------------------------------------------

    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) {
        return const SplashScreen();
      },
    ),

    // --------------------------------------------------
    // AUTH
    // --------------------------------------------------
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),

    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),

    // --------------------------------------------------
    // MAIN APP
    // --------------------------------------------------
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),

    GoRoute(
      path: '/contacts',
      name: 'contacts',
      builder: (context, state) {
        return const ContactsScreen();
      },
    ),

    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) {
        return const ProfileScreen();
      },
    ),

    GoRoute(
      path: '/calls',
      name: 'calls',
      builder: (context, state) {
        return const CallHistoryScreen();
      },
    ),

    // --------------------------------------------------
    // INCOMING CALL
    // --------------------------------------------------
    GoRoute(
      path: '/incoming-call',
      name: 'incoming-call',
      builder: (context, state) {
        final data = state.extra;

        if (data is! Map<String, dynamic>) {
          return const _InvalidCallDataScreen();
        }

        final callId = data['callId'];
        final caller = data['caller'];
        final callType = data['callType'];

        if (callId is! String ||
            caller is! UserModel ||
            callType is! call_model.CallType) {
          return const _InvalidCallDataScreen();
        }

        return IncomingCallScreen(
          callId: callId,
          caller: caller,
          callType: callType,
        );
      },
    ),

    // --------------------------------------------------
    // AUDIO CALL
    // --------------------------------------------------
    GoRoute(
      path: '/audio-call',
      name: 'audio-call',
      builder: (context, state) {
        final data = state.extra;

        if (data is! Map<String, dynamic> || data['callId'] is! String) {
          return const _InvalidCallDataScreen();
        }

        return AudioCallScreen(
          callId: data['callId'] as String,
          receiver: data['receiver'] is UserModel
              ? data['receiver'] as UserModel
              : null,
          isCaller: data['isCaller'] is bool ? data['isCaller'] as bool : true,
        );
      },
    ),

    // --------------------------------------------------
    // VIDEO CALL
    // --------------------------------------------------
    GoRoute(
      path: '/video-call',
      name: 'video-call',
      builder: (context, state) {
        final data = state.extra;

        if (data is! Map<String, dynamic> || data['callId'] is! String) {
          return const _InvalidCallDataScreen();
        }

        return VideoCallScreen(
          callId: data['callId'] as String,
          receiver: data['receiver'] is UserModel
              ? data['receiver'] as UserModel
              : null,
          isCaller: data['isCaller'] is bool ? data['isCaller'] as bool : true,
        );
      },
    ),
  ],
);

class _InvalidCallDataScreen extends StatelessWidget {
  const _InvalidCallDataScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Invalid call data')));
  }
}
