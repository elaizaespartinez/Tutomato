import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/page_width.dart';
import '../friends/friends_screen.dart';
import '../home/home_screen.dart';
import '../pomodori/pomodori_screen.dart';
import '../records/records_screen.dart';
import 'create_sheet.dart';
import 'desktop_sidebar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0; // 0 Home, 1 Pomodori, 2 Records, 3 Friends

  Widget _item(int i, IconData icon, String label) => _NavItem(
    icon: icon,
    label: label,
    selected: _index == i,
    onTap: () => setState(() => _index = i),
  );

  // Phone navigation
  Widget _bottomBar(BuildContext context) => SafeArea(
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
  );

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(onOpenPomodori: () => setState(() => _index = 1)),
      const PomodoriScreen(),
      const RecordsScreen(),
      const FriendsScreen(),
    ];
    final content = IndexedStack(index: _index, children: tabs);
    final size = Responsive.of(context);

    // Phone and tablet: same layout as the design
    if (size != ScreenSize.desktop) {
      return PageWidth(
        child: Scaffold(
          body: SafeArea(child: content),
          bottomNavigationBar: _bottomBar(context),
        ),
      );
    }

    // Laptop: full-height sidebar + centred content area
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Row(
        children: [
          DesktopSidebar(
            selectedIndex: _index,
            onSelect: (i) => setState(() => _index = i),
            onCreate: () => showCreateSheet(context),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: content,
              ),
            ),
          ),
        ],
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
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
