import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_bottom_nav.dart';
import '../../widgets/user_avatar.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  int selectedFilter = 0;

  final filters = const [
    'All',
    'Missed',
    'Incoming',
    'Outgoing',
  ];

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  15,
                  18,
                  15,
                  20,
                ),
                children: [
                  _buildHeader(),

                  const SizedBox(height: 18),

                  _buildFilters(),

                  const SizedBox(height: 22),

                  _buildSectionLabel(),

                  const SizedBox(height: 10),

                  ...filteredCalls.map(
                    (call) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Call History',
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
            Icons.search_rounded,
            size: 19,
            color: Color(0xFF08B1D0),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          filters.length,
          (index) {
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
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF08B1D0)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF08B1D0)
                          : const Color(0xFFE5ECF2),
                    ),
                  ),
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF71869A),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionLabel() {
    return Row(
      children: [
        const Text(
          'RECENT',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
            color: Color(0xFF7D91A7),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          '${filteredCalls.length}',
          style: const TextStyle(
            fontSize: 9,
            color: Color(0xFF9AABBA),
          ),
        ),
      ],
    );
  }
}

class _CallHistoryTile extends StatelessWidget {
  final _Call call;

  const _CallHistoryTile({
    required this.call,
  });

  @override
  Widget build(BuildContext context) {
    final missed = call.type == CallType.missed;

    final statusColor = missed
        ? const Color(0xFFFF5258)
        : const Color(0xFF08B1D0);

    final directionIcon = switch (call.type) {
      CallType.incoming => Icons.south_west_rounded,
      CallType.outgoing => Icons.north_east_rounded,
      CallType.missed => Icons.phone_missed_rounded,
    };

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAF0F5),
        ),
      ),
      child: Row(
        children: [
          UserAvatar(
            initials: call.initials,
            color: call.color,
            size: 42,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.name,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF26364A),
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      directionIcon,
                      size: 11,
                      color: statusColor,
                    ),

                    const SizedBox(width: 4),

                    Icon(
                      call.mode == CallMode.video
                          ? Icons.videocam_rounded
                          : Icons.phone_rounded,
                      size: 10,
                      color: const Color(0xFF8A9CAE),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      call.duration,
                      style: TextStyle(
                        fontSize: 9,
                        color: missed
                            ? const Color(0xFFFF5258)
                            : const Color(0xFF8A9CAE),
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      '• ${call.date}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF9AABBA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              call.mode == CallMode.video
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

enum CallType {
  incoming,
  outgoing,
  missed,
}

enum CallMode {
  audio,
  video,
}

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