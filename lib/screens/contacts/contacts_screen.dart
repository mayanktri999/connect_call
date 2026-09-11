import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_system.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../auth/user_service.dart';
import '../calls/call_services.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/user_avatar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // FILTER USERS
  // ------------------------------------------------------------

  List<UserModel> _filterUsers(List<UserModel> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }

    return users.where((user) {
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();

      return name.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();
  }

  // ------------------------------------------------------------
  // START CALL
  // ------------------------------------------------------------

  Future<void> _startCall({
    required UserModel user,
    required CallType type,
  }) async {
    final currentUser = _currentUser;

    if (currentUser == null) {
      return;
    }

    // Don't allow calling yourself.
    if (currentUser.uid == user.uid) {
      _showMessage('You cannot call yourself');
      return;
    }

    // Only allow calls when the other user is online.
    if (!user.isOnline) {
      _showMessage('${user.name} is currently offline');
      return;
    }

    try {
      // --------------------------------------------------------
      // CREATE FIRESTORE CALL
      // --------------------------------------------------------

      final callId = await CallService.instance.createCall(
        callerId: currentUser.uid,
        receiverId: user.uid,
        type: type,
      );

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // OPEN CALL SCREEN
      // --------------------------------------------------------

      if (type == CallType.audio) {
        context.push(
          '/audio-call',
          extra: {'callId': callId, 'receiver': user, 'isCaller': true},
        );
      } else {
        context.push(
          '/video-call',
          extra: {'callId': callId, 'receiver': user, 'isCaller': true},
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to create call: $e');

      if (!mounted) {
        return;
      }

      _showMessage('Unable to start call');
    }
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ------------------------------------------------------------
  // USER TILE
  // ------------------------------------------------------------

  Widget _buildUserTile(UserModel user) {
    final initials = user.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      height: AppDesignSystem.contactItemHeight,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDesignSystem.appCardRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          UserAvatar(
            initials: initials.isEmpty ? 'U' : initials,
            color: AppColors.primary,
            online: user.isOnline,
            size: AppDesignSystem.avatarMedium,
          ),

          const SizedBox(width: 12),

          // ----------------------------------------------------
          // NAME + STATUS
          // ----------------------------------------------------
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? 'Unknown User' : user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user.isOnline ? Colors.green : Colors.grey,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      user.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: user.isOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ----------------------------------------------------
          // AUDIO CALL
          // ----------------------------------------------------
          IconButton(
            onPressed: user.isOnline
                ? () => _startCall(user: user, type: CallType.audio)
                : null,
            icon: const Icon(Icons.call_outlined),
          ),

          // ----------------------------------------------------
          // VIDEO CALL
          // ----------------------------------------------------
          IconButton(
            onPressed: user.isOnline
                ? () => _startCall(user: user, type: CallType.video)
                : null,
            icon: const Icon(Icons.videocam_outlined),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // USERS SECTION
  // ------------------------------------------------------------

  Widget _buildUsers(List<UserModel> users) {
    final filteredUsers = _filterUsers(users);

    if (filteredUsers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text('No users found', style: TextStyle(fontSize: 15)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return _buildUserTile(filteredUsers[index]);
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currentUser = _currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Please login again')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: StreamBuilder<List<UserModel>>(
          stream: UserService.instance.getUsers(currentUserId: currentUser.uid),

          builder: (context, snapshot) {
            // --------------------------------------------------
            // LOADING
            // --------------------------------------------------

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // --------------------------------------------------
            // ERROR
            // --------------------------------------------------

            if (snapshot.hasError) {
              debugPrint(
                '❌ Users stream error: '
                '${snapshot.error}',
              );

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 42),

                      const SizedBox(height: 12),

                      const Text(
                        'Unable to load contacts',
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final users = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: AppDesignSystem.appPagePadding,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------
                  // HEADER
                  // ------------------------------------------------

                  const SizedBox(height: 8),

                  const Text(
                    'Contacts',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // SEARCH
                  // ------------------------------------------------
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDesignSystem.searchRadius,
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search contacts',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ------------------------------------------------
                  // ONLINE COUNT
                  // ------------------------------------------------
                  Row(
                    children: [
                      const Text(
                        'Contacts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        '${users.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ------------------------------------------------
                  // USERS
                  // ------------------------------------------------
                  _buildUsers(users),

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),

      // ----------------------------------------------------------
      // BOTTOM NAVIGATION
      // ----------------------------------------------------------
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;

            case 1:
              context.go('/contacts');
              break;

            case 2:
              context.go('/calls');
              break;

            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}
