import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.people_alt_rounded, 'Contacts'),
    (Icons.history_rounded, 'Calls'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.only(top: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EEF4))),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A08B9D8),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_items.length, (index) {
          final selected = currentIndex == index;
          final item = _items[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 38,
                    height: 30,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE4F9FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.$1,
                      size: 20,
                      color: selected
                          ? const Color(0xFF08B5D0)
                          : const Color(0xFF91A5BA),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF08B5D0)
                          : const Color(0xFF91A5BA),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
