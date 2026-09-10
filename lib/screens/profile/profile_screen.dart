import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_system.dart';
import '../../models/user_model.dart';
import '../auth/auth_service.dart';
import '../auth/user_service.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/user_avatar.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadUser();
  }

  Future<void> _loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      final user = await UserService.instance.getUser(firebaseUser.uid);

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load user: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDesignSystem.createScreenBackground(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppDesignSystem.pagePadding.copyWith(
                    top: 18,
                    bottom: 24,
                  ),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildProfile(),
                    const SizedBox(height: 20),
                    _buildStats(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Account'),
                    const SizedBox(height: 10),
                    _buildAccountCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Settings'),
                    const SizedBox(height: 10),
                    _buildSettingsCard(),
                    const SizedBox(height: 18),
                    _buildLogoutButton(context),
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
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
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
          child: const Icon(
            Icons.edit_rounded,
            size: 19,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    final name = _user?.name.isNotEmpty == true
        ? _user!.name
        : 'User';

    final email = _user?.email.isNotEmpty == true
        ? _user!.email
        : FirebaseAuth.instance.currentUser?.email ?? '';

    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [AppDesignSystem.softShadow],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                initials: initials.isEmpty ? 'U' : initials,
                color: AppColors.primary,
                online: _user?.isOnline ?? true,
                size: 92,
              ),
              Positioned(
                right: -2,
                bottom: 2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _isLoading ? 'Loading...' : name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE9FBF3),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              (_user?.isOnline ?? true) ? 'Online' : 'Offline',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLoading ? '' : email,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [AppDesignSystem.softShadow],
      ),
      child: Row(
        children: [
          const _StatItem(
            value: '24',
            label: 'Contacts',
          ),
          _verticalDivider(),
          const _StatItem(
            value: '128',
            label: 'Calls',
          ),
          _verticalDivider(),
          const _StatItem(
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
      color: AppColors.cardBorder,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: .8,
        color: AppColors.labelText,
      ),
    );
  }

  Widget _buildAccountCard() {
    final email = _user?.email.isNotEmpty == true
        ? _user!.email
        : FirebaseAuth.instance.currentUser?.email ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [AppDesignSystem.softShadow],
      ),
      child: Column(
        children: [
          _ProfileRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: _isLoading ? 'Loading...' : email,
          ),
          _divider(),
          const _ProfileRow(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: '+91 98765 43210',
          ),
          _divider(),
          _ProfileRow(
            icon: Icons.circle,
            title: 'Status',
            value: (_user?.isOnline ?? true) ? 'Available' : 'Offline',
            valueColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [AppDesignSystem.softShadow],
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

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
       final user = FirebaseAuth.instance.currentUser;

if (user != null) {
  await UserService.instance.updateOnlineStatus(
    user.uid,
    false,
  );
}

await AuthService.instance.logout();

        if (!context.mounted) return;

        context.go('/login');
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD9DC),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 18,
              color: Color(0xFFE54850),
            ),
            SizedBox(width: 8),
            Text(
              'Log out',
              style: TextStyle(
                fontSize: 12,
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
      color: AppColors.cardBorder,
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
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 11),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.darkText,
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
              size: 18,
              color: AppColors.secondaryText,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.secondaryText,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}