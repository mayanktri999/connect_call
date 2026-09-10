import 'package:go_router/go_router.dart';

import '../screens/calls/incoming_call_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/calls/call_history_screen.dart' show CallHistoryScreen;
import '../screens/contacts/contacts_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/calls/audio_call_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/call_model.dart';
import '../models/user_model.dart';
import '../screens/calls/video_call_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final isSplash = state.matchedLocation == '/splash';
    final isLogin = state.matchedLocation == '/login';
    final isRegister = state.matchedLocation == '/register';

    // Let logged-out users access authentication screens.
    if (user == null) {
      if (isSplash || isLogin || isRegister) {
        return null;
      }

      return '/login';
    }

    // Logged-in users should not go back to login/register.
    if (isLogin || isRegister) {
      return '/home';
    }

    return null;
  },
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
      path: '/video-call',
      name: 'video-call',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return VideoCallScreen(
          callId: data['callId'] as String,
          receiver: data['receiver'] as UserModel,
        );
      },
    ),
    GoRoute(
      path: '/audio-call',
      name: 'audio-call',
      builder: (context, state) => const AudioCallScreen(),
    ),
    GoRoute(
      path: '/incoming-call',
      name: 'incoming-call',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return IncomingCallScreen(
          callId: data['callId'] as String,
          caller: data['caller'] as UserModel,
          callType: data['callType'] as CallType,
        );
      },
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
