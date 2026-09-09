import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_system.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/search_field.dart';
import '../../widgets/user_avatar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  int selectedNavIndex = 1;

  final List<_Contact> onlineContacts = [
    _Contact(
      name: 'Sarah Johnson',
      status: 'Available',
      initials: 'SJ',
      color: Color(0xFF22A8E0),
    ),
    _Contact(
      name: 'Alex Wilson',
      status: 'Available',
      initials: 'AW',
      color: Color(0xFF20B989),
    ),
    _Contact(
      name: 'Emma Davis',
      status: 'Busy',
      initials: 'ED',
      color: Color(0xFFF5A51C),
      busy: true,
    ),
    _Contact(
      name: 'Priya Patel',
      status: 'Available',
      initials: 'PP',
      color: Color(0xFFE84C91),
    ),
  ];

  final List<_Contact> offlineContacts = [
    _Contact(
      name: 'John Smith',
      status: 'Offline',
      initials: 'JS',
      color: Color(0xFF8A5CF5),
    ),
    _Contact(
      name: 'David Miller',
      status: 'Offline',
      initials: 'DM',
      color: Color(0xFF607D8B),
    ),
  ];

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
                    bottom: 20,
                  ),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    const AppSearchField(hintText: 'Search contacts...'),
                    const SizedBox(height: 22),
                    _buildSectionTitle('Online', '${onlineContacts.length}'),
                    const SizedBox(height: 10),
                    ...onlineContacts.map(
                      (contact) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ContactTile(contact: contact),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionTitle('Offline', '${offlineContacts.length}'),
                    const SizedBox(height: 10),
                    ...offlineContacts.map(
                      (contact) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ContactTile(contact: contact),
                      ),
                    ),
                  ],
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
            border: Border.all(color: AppColors.cardBorder),
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

  Widget _buildSectionTitle(String title, String count) {
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
}

class _ContactTile extends StatelessWidget {
  final _Contact contact;

  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final bool online = contact.status != 'Offline';

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
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
            initials: contact.initials,
            color: contact.color,
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
                  contact.name,
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
                            ? contact.busy
                                  ? const Color(0xFFF5A51C)
                                  : const Color(0xFF10B981)
                            : const Color(0xFF9AA9B8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      contact.status,
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
            onTap: () {
              // Audio call will be connected later.
            },
          ),
          const SizedBox(width: 8),
          _CallIconButton(
            icon: Icons.videocam_rounded,
            enabled: online,
            onTap: () {
              // Video call will be connected later.
            },
          ),
        ],
      ),
    );
  }
}

class _CallIconButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

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
          color: enabled ? const Color(0xFFEAF8FC) : const Color(0xFFF3F5F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled ? const Color(0xFF08B1D0) : const Color(0xFFB5C0CA),
        ),
      ),
    );
  }
}

class _Contact {
  final String name;
  final String status;
  final String initials;
  final Color color;
  final bool busy;

  const _Contact({
    required this.name,
    required this.status,
    required this.initials,
    required this.color,
    this.busy = false,
  });
}
