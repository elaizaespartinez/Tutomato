import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/page_width.dart';
import '../../core/widgets/placeholder_screen.dart';
import 'create_sheet.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0; // 0 Home, 1 Pomodori, 2 Records, 3 Friends

  // Swap each placeholder for the real screen as you build it.
  static const _tabs = [
    PlaceholderScreen('Home'),
    PlaceholderScreen('Your Pomodori'),
    PlaceholderScreen('Your records'),
    PlaceholderScreen('Better together'),
  ];

  Widget _item(int i, IconData icon, String label) => _NavItem(
    icon: icon,
    label: label,
    selected: _index == i,
    onTap: () => setState(() => _index = i),
  );

  @override
  Widget build(BuildContext context) {
    return PageWidth(
      child: Scaffold(
        body: SafeArea(child: IndexedStack(index: _index, children: _tabs)),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _item(0, Icons.home_outlined, 'Home'),
                _item(1, Icons.eco_outlined, 'Pomodori'),
                GestureDetector(
                  onTap: () => showCreateSheet(context),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.tomato,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
                _item(2, Icons.bar_chart, 'Records'),
                _item(3, Icons.people_outline, 'Friends'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.tomato : AppColors.brownSoft;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppColors.peach : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color),
            ),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}