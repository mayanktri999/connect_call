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
  int selectedNavIndex = 1;

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login again.'),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppDesignSystem.createScreenBackground(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<UserModel>>(
                  stream: UserService.instance.getUsers(
                    currentUserId: currentUser.uid,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Unable to load contacts.\n\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final users = snapshot.data ?? [];

                    final filteredUsers = users.where((user) {
                      final query = searchQuery.toLowerCase();

                      return user.name.toLowerCase().contains(query) ||
                          user.email.toLowerCase().contains(query);
                    }).toList();

                    final onlineUsers = filteredUsers
                        .where((user) => user.isOnline)
                        .toList();

                    final offlineUsers = filteredUsers
                        .where((user) => !user.isOnline)
                        .toList();

                    return ListView(
                      padding: AppDesignSystem.pagePadding.copyWith(
                        top: 18,
                        bottom: 20,
                      ),
                      children: [
                        _buildHeader(),

                        const SizedBox(height: 18),

                        _SearchField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),

                        const SizedBox(height: 22),

                        _buildSectionTitle(
                          'Online',
                          '${onlineUsers.length}',
                        ),

                        const SizedBox(height: 10),

                        if (onlineUsers.isEmpty)
                          _buildEmptyMessage(
                            'No online contacts',
                          )
                        else
                          ...onlineUsers.map(
                            (user) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: _ContactTile(
                                user: user,
                                onAudioCall: () {
                                  _startCall(
                                    user,
                                    CallType.audio,
                                  );
                                },
                                onVideoCall: () {
                                  _startCall(
                                    user,
                                    CallType.video,
                                  );
                                },
                              ),
                            ),
                          ),

                        const SizedBox(height: 18),

                        _buildSectionTitle(
                          'Offline',
                          '${offlineUsers.length}',
                        ),

                        const SizedBox(height: 10),

                        if (offlineUsers.isEmpty)
                          _buildEmptyMessage(
                            'No offline contacts',
                          )
                        else
                          ...offlineUsers.map(
                            (user) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: _ContactTile(
                                user: user,
                                onAudioCall: null,
                                onVideoCall: null,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              AppBottomNav(
                currentIndex: selectedNavIndex,
                onTap: (index) {
                  setState(() {
                    selectedNavIndex = index;
                  });

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
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // START CALL
  // ----------------------------------------------------------

  Future<void> _startCall(
    UserModel user,
    CallType type,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage('Please login again.');
      return;
    }

    try {
      final callId = await CallService.instance.createCall(
        callerId: currentUser.uid,
        receiverId: user.uid,
        type: type,
      );

      if (!mounted) return;

      if (type == CallType.audio) {
        context.push(
          '/audio-call',
          extra: {
            'callId': callId,
            'receiver': user,
          },
        );
      } else {
        context.push(
          '/video-call',
          extra: {
            'callId': callId,
            'receiver': user,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to start call: $e',
      );
    }
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Contacts',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
        ),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.cardBorder,
            ),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // SECTION TITLE
  // ----------------------------------------------------------

  Widget _buildSectionTitle(
    String title,
    String count,
  ) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.labelText,
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // EMPTY MESSAGE
  // ----------------------------------------------------------

  Widget _buildEmptyMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 22,
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

// ============================================================
// SEARCH FIELD
// ============================================================

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search contacts...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.secondaryText,
        ),
        filled: true,
        fillColor: AppColors.fieldBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.fieldBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.fieldBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CONTACT TILE
// ============================================================

class _ContactTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onAudioCall;
  final VoidCallback? onVideoCall;

  const _ContactTile({
    required this.user,
    required this.onAudioCall,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    final bool online = user.isOnline;

    final initials = _getInitials(user.name);

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          UserAvatar(
            initials: initials,
            color: AppColors.primary,
            online: online,
            size: 42,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty
                      ? 'Unknown User'
                      : user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: online
                            ? const Color(0xFF10B981)
                            : const Color(0xFF9AA9B8),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      online ? 'Available' : 'Offline',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _CallIconButton(
            icon: Icons.phone_rounded,
            enabled: online,
            onTap: onAudioCall,
          ),

          const SizedBox(width: 8),

          _CallIconButton(
            icon: Icons.videocam_rounded,
            enabled: online,
            onTap: onVideoCall,
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(
        0,
        parts.first.length >= 2 ? 2 : 1,
      ).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ============================================================
// CALL BUTTON
// ============================================================

class _CallIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _CallIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 31,
        height: 31,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFEAF8FC)
              : const Color(0xFFF3F5F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled
              ? const Color(0xFF08B1D0)
              : const Color(0xFFB5C0CA),
        ),
      ),
    );
  }
}