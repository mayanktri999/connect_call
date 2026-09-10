import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_system.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../auth/presence_service.dart';
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
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  User? get _currentUser =>
      FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // START AUDIO / VIDEO CALL
  // ------------------------------------------------------------

  Future<void> _startCall({
    required UserModel user,
    required CallType type,
  }) async {
    final currentUser = _currentUser;

    if (currentUser == null) {
      return;
    }

    try {
      final callId =
          await CallService.instance.createCall(
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
      debugPrint('Start call error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to start call. Please try again.',
          ),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // FILTER USERS
  // ------------------------------------------------------------

  List<UserModel> _filterUsers(
    List<UserModel> users,
    Map<String, bool> presence,
  ) {
    final updatedUsers = users.map((user) {
      return UserModel(
        uid: user.uid,
        name: user.name,
        email: user.email,
        profileImage: user.profileImage,

        // IMPORTANT:
        // RTDB presence is used here.
        isOnline: presence[user.uid] ?? false,

        createdAt: user.createdAt,
      );
    }).toList();

    if (_searchQuery.isEmpty) {
      return updatedUsers;
    }

    return updatedUsers.where((user) {
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();

      return name.contains(_searchQuery) ||
          email.contains(_searchQuery);
    }).toList();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currentUser = _currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login again.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            _buildSearchField(),

            const SizedBox(height: 18),

            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: UserService.instance.getUsers(
                  currentUserId: currentUser.uid,
                ),

                builder: (context, userSnapshot) {
                  // ------------------------------------------------
                  // ONLY WAIT FOR FIRESTORE USERS
                  // ------------------------------------------------

                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (userSnapshot.hasError) {
                    debugPrint(
                      'Contacts Firestore error: '
                      '${userSnapshot.error}',
                    );

                    return _buildErrorState(
                      'Unable to load contacts.',
                    );
                  }

                  final users =
                      userSnapshot.data ?? [];

                  // ------------------------------------------------
                  // PRESENCE IS OPTIONAL
                  //
                  // We DO NOT show a loading screen while
                  // Realtime Database is connecting.
                  // ------------------------------------------------

                  return StreamBuilder<Map<String, bool>>(
                    stream: PresenceService.instance
                        .presenceStream(),

                    builder:
                        (context, presenceSnapshot) {
                      // If RTDB hasn't returned anything yet,
                      // simply treat everyone as offline.
                      //
                      // Contacts still appear immediately.
                      final presence =
                          presenceSnapshot.data ??
                              <String, bool>{};

                      final filteredUsers =
                          _filterUsers(
                        users,
                        presence,
                      );

                      final onlineUsers =
                          filteredUsers
                              .where(
                                (user) =>
                                    user.isOnline,
                              )
                              .toList();

                      final offlineUsers =
                          filteredUsers
                              .where(
                                (user) =>
                                    !user.isOnline,
                              )
                              .toList();

                      if (filteredUsers.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          // Firestore StreamBuilder automatically
                          // updates when data changes.
                          //
                          // Small delay gives RefreshIndicator
                          // enough time to animate properly.
                          await Future<void>.delayed(
                            const Duration(
                              milliseconds: 300,
                            ),
                          );
                        },

                        child: ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),

                          padding:
                              const EdgeInsets.fromLTRB(
                            15,
                            0,
                            15,
                            100,
                          ),

                          children: [
                            // ------------------------------
                            // ONLINE USERS
                            // ------------------------------

                            if (onlineUsers.isNotEmpty)
                              _buildSection(
                                title: 'Online',
                                count:
                                    onlineUsers.length,
                                users: onlineUsers,
                                showOnline: true,
                              ),

                            if (onlineUsers.isNotEmpty &&
                                offlineUsers.isNotEmpty)
                              const SizedBox(
                                height: 22,
                              ),

                            // ------------------------------
                            // OFFLINE USERS
                            // ------------------------------

                            if (offlineUsers.isNotEmpty)
                              _buildSection(
                                title: 'Contacts',
                                count:
                                    offlineUsers.length,
                                users: offlineUsers,
                                showOnline: false,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        15,
        16,
        15,
        12,
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Contacts',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Connect with your friends',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color:
                            AppColors.secondaryText,
                      ),
                ),
              ],
            ),
          ),

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.cardBorder,
              ),
            ),

            child: IconButton(
              onPressed: () {
                _searchController.clear();
              },

              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
              ),

              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  Widget _buildSearchField() {
    return Padding(
      padding: AppDesignSystem.sectionPadding,

      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              AppDesignSystem.searchRadius,
          border: Border.all(
            color: AppColors.cardBorder,
          ),
        ),

        child: TextField(
          controller: _searchController,

          textInputAction:
              TextInputAction.search,

          decoration: InputDecoration(
            hintText: 'Search contacts',

            hintStyle: TextStyle(
              color: AppColors.secondaryText,
            ),

            prefixIcon: const Icon(
              Icons.search_rounded,
            ),

            suffixIcon:
                _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController
                              .clear();
                        },

                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      )
                    : null,

            border: InputBorder.none,

            contentPadding:
                AppDesignSystem.searchPadding,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION
  // ------------------------------------------------------------

  Widget _buildSection({
    required String title,
    required int count,
    required List<UserModel> users,
    required bool showOnline,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 4,
          ),

          child: Row(
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
              ),

              const SizedBox(width: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),

                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: Text(
                  '$count',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                        color:
                            AppColors.secondaryText,
                      ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        ...users.map(
          (user) => Padding(
            padding:
                const EdgeInsets.only(
              bottom: 10,
            ),

            child: _ContactTile(
              user: user,

              online: showOnline,

              onAudioCall: showOnline
                  ? () => _startCall(
                        user: user,
                        type: CallType.audio,
                      )
                  : null,

              onVideoCall: showOnline
                  ? () => _startCall(
                        user: user,
                        type: CallType.video,
                      )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 72,
              height: 72,

              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(24),
              ),

              child: const Icon(
                Icons.people_outline_rounded,
                size: 34,
                color:
                    AppColors.secondaryText,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              _searchQuery.isEmpty
                  ? 'No contacts yet'
                  : 'No contacts found',

              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.w700,
                  ),
            ),

            const SizedBox(height: 6),

            Text(
              _searchQuery.isEmpty
                  ? 'Your contacts will appear here.'
                  : 'Try searching with another name or email.',

              textAlign: TextAlign.center,

              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color:
                        AppColors.secondaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ERROR STATE
  // ------------------------------------------------------------

  Widget _buildErrorState(
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Colors.red,
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: () {
                setState(() {});
              },

              child: const Text(
                'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// CONTACT TILE
// ==================================================================

class _ContactTile extends StatelessWidget {
  final UserModel user;
  final bool online;
  final VoidCallback? onAudioCall;
  final VoidCallback? onVideoCall;

  const _ContactTile({
    required this.user,
    required this.online,
    this.onAudioCall,
    this.onVideoCall,
  });

  // ------------------------------------------------------------
  // INITIALS
  // ------------------------------------------------------------

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty ||
        parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          AppDesignSystem.contactItemHeight,

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius:
            AppDesignSystem.appCardRadius,

        border: Border.all(
          color: AppColors.cardBorder,
        ),
      ),

      child: Row(
        children: [
          // ------------------------------------------------------
          // AVATAR
          // ------------------------------------------------------

          UserAvatar(
            initials: _initials(user.name),
            color: AppColors.primary,
            size: AppDesignSystem.avatarMedium,
            online: online,
          ),

          const SizedBox(width: 12),

          // ------------------------------------------------------
          // NAME + STATUS
          // ------------------------------------------------------

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  user.name.isEmpty
                      ? 'Unknown User'
                      : user.name,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                ),

                const SizedBox(height: 3),

                Text(
                  online ? 'Online' : 'Offline',

                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: online
                            ? Colors.green
                            : AppColors
                                .secondaryText,

                        fontWeight: online
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // ------------------------------------------------------
          // AUDIO CALL
          // ------------------------------------------------------

          _CallIconButton(
            icon: Icons.call_rounded,
            enabled: online,
            onPressed: onAudioCall,
          ),

          const SizedBox(width: 6),

          // ------------------------------------------------------
          // VIDEO CALL
          // ------------------------------------------------------

          _CallIconButton(
            icon: Icons.videocam_rounded,
            enabled: online,
            onPressed: onVideoCall,
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// CALL ICON BUTTON
// ==================================================================

class _CallIconButton
    extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onPressed;

  const _CallIconButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          AppDesignSystem.iconButtonSize,

      height:
          AppDesignSystem.iconButtonSize,

      child: Material(
        color: enabled
            ? AppColors.primary
                .withOpacity(0.10)
            : AppColors.fieldBackground,

        borderRadius:
            BorderRadius.circular(12),

        child: InkWell(
          borderRadius:
              BorderRadius.circular(12),

          onTap:
              enabled ? onPressed : null,

          child: Icon(
            icon,

            size: 18,

            color: enabled
                ? AppColors.primary
                : AppColors.secondaryText
                    .withOpacity(0.45),
          ),
        ),
      ),
    );
  }
}