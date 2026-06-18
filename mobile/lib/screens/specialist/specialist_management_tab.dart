import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistManagementTab extends StatefulWidget {
  const SpecialistManagementTab({super.key});

  @override
  State<SpecialistManagementTab> createState() => _SpecialistManagementTabState();
}

class _SpecialistManagementTabState extends State<SpecialistManagementTab> {
  ContentStatsModel? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stats = await context.read<AppState>().loadContentStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'إدارة المحتوى والمستخدمين',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_stats != null)
          PlayfulCard(
            accent: AppTheme.purple,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _countTile('عوالم', _stats!.worldsCount),
                _countTile('كلمات', _stats!.itemsCount),
                _countTile('أنشطة', _stats!.activitiesCount),
              ],
            ),
          ),
        const SizedBox(height: 16),
        _menuTile(
          icon: Icons.public,
          title: 'العوالم التعليمية',
          subtitle: 'إضافة وتعديل وحذف العوالم',
          color: AppTheme.grass,
          onTap: () => context.push('/specialist/content/worlds'),
        ),
        _menuTile(
          icon: Icons.abc,
          title: 'الكلمات',
          subtitle: 'إدارة كلمات كل عالم',
          color: AppTheme.orange,
          onTap: () => context.push('/specialist/content/items'),
        ),
        _menuTile(
          icon: Icons.extension,
          title: 'الأنشطة',
          subtitle: 'أنشطة التعرف والنطق والتمييز',
          color: AppTheme.teal,
          onTap: () => context.push('/specialist/content/activities'),
        ),
        _menuTile(
          icon: Icons.people,
          title: 'المستخدمون',
          subtitle: 'إدارة حسابات أولياء الأمور والأخصائيين',
          color: AppTheme.purple,
          onTap: () => context.push('/specialist/users'),
        ),
      ],
    );
  }

  Widget _countTile(String label, int count) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        Text(label),
      ],
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: PlayfulCard(
            accent: color,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}
