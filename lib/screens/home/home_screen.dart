import 'package:flutter/material.dart';

import '../../core/theme/app_design_system.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/search_field.dart';
import '../../widgets/user_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppDesignSystem.appPagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 15),

                    const AppSearchField(),

                    const SizedBox(height: 28),

                    _buildCallActions(),

                    const SizedBox(height: 21),

                    _buildOnlineSection(),

                    const SizedBox(height: 24),

                    _buildRecentHeader(),

                    const SizedBox(height: 10),

                    _buildRecentCalls(),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            AppBottomNav(
              currentIndex: 0,
              onTap: (index) {
                // Navigation will be connected later.
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        const UserAvatar(
          initials: 'MS',
          color: Color(0xFF19B5D3),
          online: true,
          size: 38,
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8EA2B7),
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Mayank 👋',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF172033),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: Color(0xFF60758B),
                ),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF08B5D0),
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

  // ─────────────────────────────────────────────
  // CALL ACTIONS
  // ─────────────────────────────────────────────

  Widget _buildCallActions() {
    return Row(
      children: [
        Expanded(
          child: _CallActionCard(
            title: 'Audio Call',
            icon: Icons.phone_rounded,
            filled: true,
            onTap: () {},
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _CallActionCard(
            title: 'Video Call',
            icon: Icons.videocam_rounded,
            filled: false,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // ONLINE
  // ─────────────────────────────────────────────

  Widget _buildOnlineSection() {
    final users = [
      ('SJ', 'Sarah', const Color(0xFF22A8E0)),
      ('AW', 'Alex', const Color(0xFF20B989)),
      ('ED', 'Emma', const Color(0xFFF5A51C)),
      ('SW', 'Sarah', const Color(0xFF20B4CD)),
      ('PP', 'Priya', const Color(0xFFE84C91)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Online now',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF172033),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FBF4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '5 active',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0CB47B),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: users.map((user) {
            return Column(
              children: [
                UserAvatar(
                  initials: user.$1,
                  color: user.$3,
                  online: true,
                  size: 38,
                ),
                const SizedBox(height: 5),
                Text(
                  user.$2,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF52657A),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // RECENT CALLS
  // ─────────────────────────────────────────────

  Widget _buildRecentHeader() {
    return Row(
      children: [
        const Text(
          'Recent calls',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172033),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'See all',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF08AFCB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCalls() {
    return Column(
      children: [
        _RecentCallTile(
          initials: 'SJ',
          name: 'Sarah Johnson',
          color: const Color(0xFF22A8E0),
          duration: '02:35',
          time: 'Today',
          video: true,
          outgoing: true,
        ),
        const SizedBox(height: 7),
        _RecentCallTile(
          initials: 'JS',
          name: 'John Smith',
          color: const Color(0xFF8A5CF5),
          duration: 'Missed',
          time: 'Yesterday',
          video: false,
          outgoing: false,
          missed: true,
        ),
        const SizedBox(height: 7),
        _RecentCallTile(
          initials: 'AW',
          name: 'Alex Wilson',
          color: const Color(0xFF20B989),
          duration: '08:12',
          time: 'Yesterday',
          video: false,
          outgoing: true,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// CALL ACTION CARD
// ═══════════════════════════════════════════════

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
        height: 96,
        decoration: BoxDecoration(
          color: filled
              ? const Color(0xFF08B1D0)
              : const Color(0xFFEAF8FC),
          borderRadius: BorderRadius.circular(19),
          border: filled
              ? null
              : Border.all(
                  color: const Color(0xFF08B1D0),
                  width: 1,
                ),
          boxShadow: filled
              ? const [
                  BoxShadow(
                    color: Color(0x4008B1D0),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: filled
                    ? Colors.white.withOpacity(.18)
                    : const Color(0xFFD1F3FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: filled
                    ? Colors.white
                    : const Color(0xFF08B1D0),
                size: 19,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: filled
                    ? Colors.white
                    : const Color(0xFF08AFCB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// RECENT CALL TILE
// ═══════════════════════════════════════════════

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
        : const Color(0xFF8CA1B7);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          UserAvatar(
            initials: initials,
            color: color,
            size: 38,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF27364A),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      outgoing
                          ? Icons.north_east_rounded
                          : Icons.south_west_rounded,
                      size: 11,
                      color: missed
                          ? const Color(0xFFFF4E55)
                          : const Color(0xFF08B1D0),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      video
                          ? Icons.videocam_rounded
                          : Icons.phone_rounded,
                      size: 10,
                      color: metaColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$duration · $time',
                      style: TextStyle(
                        fontSize: 9,
                        color: metaColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              video
                  ? Icons.videocam_rounded
                  : Icons.phone_rounded,
              size: 15,
              color: const Color(0xFF667B91),
            ),
          ),
        ],
      ),
    );
  }
}