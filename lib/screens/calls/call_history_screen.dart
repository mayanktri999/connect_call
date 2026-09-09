import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design_system.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/user_avatar.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  int selectedFilter = 0;

  final filters = const ['All', 'Missed', 'Incoming', 'Outgoing'];

  final calls = const [
    _Call(
      name: 'Sarah Johnson',
      initials: 'SJ',
      color: Color(0xFF22A8E0),
      type: CallType.outgoing,
      mode: CallMode.video,
      duration: '02:35',
      date: 'Today, 10:42 AM',
    ),
    _Call(
      name: 'John Smith',
      initials: 'JS',
      color: Color(0xFF8A5CF5),
      type: CallType.missed,
      mode: CallMode.audio,
      duration: 'Missed call',
      date: 'Yesterday, 7:18 PM',
    ),
    _Call(
      name: 'Alex Wilson',
      initials: 'AW',
      color: Color(0xFF20B989),
      type: CallType.incoming,
      mode: CallMode.audio,
      duration: '08:12',
      date: 'Yesterday, 4:05 PM',
    ),
    _Call(
      name: 'Emma Davis',
      initials: 'ED',
      color: Color(0xFFF5A51C),
      type: CallType.outgoing,
      mode: CallMode.video,
      duration: '05:44',
      date: 'Sep 7, 2:32 PM',
    ),
    _Call(
      name: 'Priya Patel',
      initials: 'PP',
      color: Color(0xFFE84C91),
      type: CallType.incoming,
      mode: CallMode.video,
      duration: '11:20',
      date: 'Sep 6, 8:14 PM',
    ),
  ];

  List<_Call> get filteredCalls {
    if (selectedFilter == 0) {
      return calls;
    }

    final type = switch (selectedFilter) {
      1 => CallType.missed,
      2 => CallType.incoming,
      _ => CallType.outgoing,
    };

    return calls.where((call) => call.type == type).toList();
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
                    bottom: 20,
                  ),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildFilters(),
                    const SizedBox(height: 22),
                    _buildSectionLabel(),
                    const SizedBox(height: 12),
                    ...filteredCalls.map(
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

  Widget _buildSectionLabel() {
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
          '${filteredCalls.length}',
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
