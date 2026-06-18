import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/screens/specialist/specialist_children_tab.dart';
import 'package:klamo_mobile/screens/specialist/specialist_dashboard_tab.dart';
import 'package:klamo_mobile/screens/specialist/specialist_management_tab.dart';
import 'package:klamo_mobile/screens/specialist/specialist_recordings_tab.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:provider/provider.dart';

class SpecialistShellScreen extends StatefulWidget {
  const SpecialistShellScreen({super.key});

  @override
  State<SpecialistShellScreen> createState() => _SpecialistShellScreenState();
}

class _SpecialistShellScreenState extends State<SpecialistShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: KlamoAppBar(
        title: Text('لوحة الأخصائي • ${appState.user?.name ?? ''}'),
        actions: [
          IconButton(
            onPressed: () async {
              await appState.logout();
              if (context.mounted) context.go('/auth');
            },
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          SpecialistDashboardTab(),
          SpecialistChildrenTab(),
          SpecialistRecordingsTab(),
          SpecialistManagementTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: Colors.white,
        indicatorColor: AppTheme.teal.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.child_care_outlined),
            selectedIcon: Icon(Icons.child_care),
            label: 'الأطفال',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_outlined),
            selectedIcon: Icon(Icons.mic),
            label: 'التسجيلات',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'الإدارة',
          ),
        ],
      ),
    );
  }
}
