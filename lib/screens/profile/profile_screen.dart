import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_bottom_nav.dart';
import '../../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(15, 18, 15, 24),
                children: [
                  _buildHeader(),

                  const SizedBox(height: 22),

                  _buildProfile(),

                  const SizedBox(height: 24),

                  _buildStats(),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Account'),

                  const SizedBox(height: 10),

                  _buildAccountCard(),

                  const SizedBox(height: 22),

                  _buildSectionTitle('Settings'),

                  const SizedBox(height: 10),

                  _buildSettingsCard(),

                  const SizedBox(height: 18),

                  _buildLogoutButton(),
                ],
              ),
            ),

            AppBottomNav(
              currentIndex: 3,
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
        ),

        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.edit_rounded,
            size: 18,
            color: Color(0xFF08B1D0),
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const UserAvatar(
              initials: 'MS',
              color: Color(0xFF19B5D3),
              online: true,
              size: 92,
            ),

            Positioned(
              right: -2,
              bottom: 2,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF08B1D0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF8FAFC),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Text(
          'Mayank',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF172033),
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Online',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF10B981),
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'mayank@example.com',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF8A9CAE),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEAF0F5),
        ),
      ),
      child: Row(
        children: [
          _StatItem(
            value: '24',
            label: 'Contacts',
          ),
          _verticalDivider(),
          _StatItem(
            value: '128',
            label: 'Calls',
          ),
          _verticalDivider(),
          _StatItem(
            value: '16',
            label: 'This week',
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFE8EEF3),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: .8,
        color: Color(0xFF7D91A7),
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFEAF0F5),
        ),
      ),
      child: Column(
        children: [
          _ProfileRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: 'mayank@example.com',
          ),
          _divider(),
          _ProfileRow(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: '+91 98765 43210',
          ),
          _divider(),
          _ProfileRow(
            icon: Icons.circle,
            title: 'Status',
            value: 'Available',
            valueColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFEAF0F5),
        ),
      ),
      child: Column(
        children: [
          _ActionRow(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            onTap: () {},
          ),
          _divider(),
          _ActionRow(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy',
            onTap: () {},
          ),
          _divider(),
          _ActionRow(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFFD9DC),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 17,
              color: Color(0xFFE54850),
            ),
            SizedBox(width: 8),
            Text(
              'Log out',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE54850),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      indent: 50,
      endIndent: 15,
      color: Color(0xFFEAF0F5),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF8A9CAE),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          const SizedBox(width: 15),

          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF08B1D0),
            ),
          ),

          const SizedBox(width: 11),

          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64788D),
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF27364A),
            ),
          ),

          const SizedBox(width: 15),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 55,
        child: Row(
          children: [
            const SizedBox(width: 15),

            Icon(
              icon,
              size: 19,
              color: const Color(0xFF71869A),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27364A),
                ),
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFF9AABBA),
            ),

            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}