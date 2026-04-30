import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/colors.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = location == '/dashboard' ? 0 : 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(currentIndex: currentIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/veiculo/novo'),
        tooltip: 'Adicionar Veículo',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: kSurfaceContainerLowest,
      elevation: 0,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'DASHBOARD',
                active: currentIndex == 0,
                onTap: () => context.go('/dashboard'),
              ),
            ),
            const Expanded(child: SizedBox()), // space for FAB
            Expanded(
              child: _NavItem(
                icon: Icons.garage_outlined,
                activeIcon: Icons.garage,
                label: 'GARAGEM',
                active: currentIndex == 2,
                onTap: () => context.go('/'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? kPrimary : kOnSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? activeIcon : icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
