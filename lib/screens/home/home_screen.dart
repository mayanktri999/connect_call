import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_system.dart';
import '../../models/user_model.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/search_field.dart';
import '../../widgets/user_avatar.dart';
import '../calls/incoming_call_listners.dart';
import '../../models/call_model.dart';
import '../../providers/call_history_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      IncomingCallListener.instance.start(context);
    });
  }

  @override
  void dispose() {
    IncomingCallListener.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).valueOrNull;
    final contacts = ref.watch(contactsProvider).valueOrNull ?? const [];
    final calls = ref.watch(callHistoryProvider).valueOrNull ?? const [];

    return Scaffold(
      body: Container(
        decoration: AppDesignSystem.createScreenBackground(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: AppDesignSystem.pagePadding.copyWith(
                    top: 18,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(user?.name ?? user?.email ?? 'User'),
                      const SizedBox(height: 18),
                      const AppSearchField(),
                      const SizedBox(height: 24),
                      _buildCallActions(context),
                      const SizedBox(height: 24),
                      _buildOnlineSection(contacts),
                      const SizedBox(height: 24),
                      _buildRecentHeader(),
                      const SizedBox(height: 12),
                      _buildRecentCalls(calls, contacts, user?.uid),
                    ],
                  ),
                ),
              ),

              AppBottomNav(
                currentIndex: 0,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String displayName) {
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Row(
      children: [
        UserAvatar(
          initials: initials.isEmpty ? 'U' : initials,
          color: AppColors.primary,
          online: true,
          size: 38,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 2),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: const [AppDesignSystem.softShadow],
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: AppColors.secondaryText,
                ),
              ),
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CallActionCard(
            title: 'Audio Call',
            icon: Icons.phone_rounded,
            filled: true,
            onTap: () => context.push('/contacts'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CallActionCard(
            title: 'Video Call',
            icon: Icons.videocam_rounded,
            filled: false,
            onTap: () => context.push('/contacts'),
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineSection(List<UserModel> contacts) {
    final users = contacts.where((user) => user.isOnline).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Online now',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FBF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${users.length} active',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0CB47B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: users.take(5).map((user) {
            final initials = user.name
                .trim()
                .split(RegExp(r'\s+'))
                .where((part) => part.isNotEmpty)
                .take(2)
                .map((part) => part[0].toUpperCase())
                .join();
            return Column(
              children: [
                UserAvatar(
                  initials: initials.isEmpty ? 'U' : initials,
                  color: AppColors.primary,
                  online: user.isOnline,
                  size: 38,
                ),
                const SizedBox(height: 5),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentHeader() {
    return Row(
      children: [
        const Text(
          'Recent calls',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'See all',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCalls(
    List<CallModel> calls,
    List<UserModel> contacts,
    String? currentUserId,
  ) {
    final usersById = {for (final user in contacts) user.uid: user};

    return Column(
      children: calls.take(3).map((call) {
        final otherId = call.callerId == currentUserId
            ? call.receiverId
            : call.callerId;
        final name = usersById[otherId]?.name ?? otherId;
        final initials = name
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RecentCallTile(
            initials: initials.isEmpty ? 'U' : initials,
            name: name,
            color: AppColors.primary,
            duration: call.status == CallStatus.missed ? 'Missed' : 'Call',
            time: _formatDate(call.createdAt),
            video: call.type == CallType.video,
            outgoing: call.callerId == currentUserId,
            missed: call.status == CallStatus.missed,
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day}/${localDate.month}/${localDate.year}';
  }
}

class _CallActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _CallActionCard({
    required this.title,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 102,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: filled ? null : Border.all(color: AppColors.cardBorder),
          boxShadow: const [AppDesignSystem.softShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: filled
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: filled ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentCallTile extends StatelessWidget {
  final String initials;
  final String name;
  final Color color;
  final String duration;
  final String time;
  final bool video;
  final bool outgoing;
  final bool missed;

  const _RecentCallTile({
    required this.initials,
    required this.name,
    required this.color,
    required this.duration,
    required this.time,
    required this.video,
    required this.outgoing,
    this.missed = false,
  });

  @override
  Widget build(BuildContext context) {
    final metaColor = missed
        ? const Color(0xFFFF4E55)
        : AppColors.secondaryText;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [AppDesignSystem.softShadow],
      ),
      child: Row(
        children: [
          UserAvatar(initials: initials, color: color, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      outgoing
                          ? Icons.north_east_rounded
                          : Icons.south_west_rounded,
                      size: 12,
                      color: missed
                          ? const Color(0xFFFF4E55)
                          : AppColors.primary,
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      video ? Icons.videocam_rounded : Icons.phone_rounded,
                      size: 11,
                      color: metaColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$duration · $time',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: metaColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              video ? Icons.videocam_rounded : Icons.phone_rounded,
              size: 16,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
