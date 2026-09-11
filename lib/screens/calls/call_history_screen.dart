import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_system.dart';
import '../../models/call_model.dart' as model;
import '../../providers/auth_provider.dart';
import '../../providers/call_history_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/user_avatar.dart';

class CallHistoryScreen extends ConsumerStatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  ConsumerState<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends ConsumerState<CallHistoryScreen> {
  int selectedFilter = 0;

  final filters = const ['All', 'Missed', 'Incoming', 'Outgoing'];

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.uid;
    final contacts = ref.watch(contactsProvider).valueOrNull ?? const [];
    final calls = ref.watch(callHistoryProvider).valueOrNull ?? const [];
    final usersById = {for (final user in contacts) user.uid: user};
    final realCalls = calls
        .map((call) {
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
          final type = call.status == model.CallStatus.missed
              ? CallType.missed
              : call.callerId == currentUserId
              ? CallType.outgoing
              : CallType.incoming;

          return _Call(
            name: name,
            initials: initials.isEmpty ? 'U' : initials,
            color: AppColors.primary,
            type: type,
            mode: call.type == model.CallType.video
                ? CallMode.video
                : CallMode.audio,
            duration: call.status == model.CallStatus.missed
                ? 'Missed call'
                : 'Call',
            date: _formatDate(call.createdAt),
          );
        })
        .where((call) {
          if (selectedFilter == 0) return true;
          final type = switch (selectedFilter) {
            1 => CallType.missed,
            2 => CallType.incoming,
            _ => CallType.outgoing,
          };
          return call.type == type;
        })
        .toList();

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
                    _buildFilters(),
                    const SizedBox(height: 22),
                    _buildSectionLabel(realCalls.length),
                    const SizedBox(height: 12),
                    ...realCalls.map(
                      (call) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CallHistoryTile(call: call),
                      ),
                    ),
                  ],
                ),
              ),
              AppBottomNav(
                currentIndex: 2,
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
            'Call History',
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
            Icons.search_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = selectedFilter == index;
          return Padding(
            padding: EdgeInsets.only(
              right: index == filters.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.cardBorder,
                  ),
                  boxShadow: selected
                      ? const [AppDesignSystem.softShadow]
                      : null,
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.secondaryText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${localDate.day}/${localDate.month}/${localDate.year}';
  }

  Widget _buildSectionLabel(int count) {
    return Row(
      children: [
        const Text(
          'RECENT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
            color: AppColors.labelText,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _CallHistoryTile extends StatelessWidget {
  final _Call call;

  const _CallHistoryTile({required this.call});

  @override
  Widget build(BuildContext context) {
    final missed = call.type == CallType.missed;
    final statusColor = missed ? const Color(0xFFFF5258) : AppColors.primary;
    final directionIcon = switch (call.type) {
      CallType.incoming => Icons.south_west_rounded,
      CallType.outgoing => Icons.north_east_rounded,
      CallType.missed => Icons.phone_missed_rounded,
    };

    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [AppDesignSystem.softShadow],
      ),
      child: Row(
        children: [
          UserAvatar(initials: call.initials, color: call.color, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(directionIcon, size: 11, color: statusColor),
                    const SizedBox(width: 4),
                    Icon(
                      call.mode == CallMode.video
                          ? Icons.videocam_rounded
                          : Icons.phone_rounded,
                      size: 10,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      call.duration,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: missed
                            ? const Color(0xFFFF5258)
                            : AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '• ${call.date}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.labelText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              call.mode == CallMode.video
                  ? Icons.videocam_rounded
                  : Icons.phone_rounded,
              size: 16,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

enum CallType { incoming, outgoing, missed }

enum CallMode { audio, video }

class _Call {
  final String name;
  final String initials;
  final Color color;
  final CallType type;
  final CallMode mode;
  final String duration;
  final String date;

  const _Call({
    required this.name,
    required this.initials,
    required this.color,
    required this.type,
    required this.mode,
    required this.duration,
    required this.date,
  });
}
