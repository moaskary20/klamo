import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistContentWorldsScreen extends StatefulWidget {
  const SpecialistContentWorldsScreen({super.key});

  @override
  State<SpecialistContentWorldsScreen> createState() =>
      _SpecialistContentWorldsScreenState();
}

class _SpecialistContentWorldsScreenState extends State<SpecialistContentWorldsScreen> {
  List<WorldModel> _worlds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final worlds = await context.read<AppState>().loadAdminWorlds();
    if (!mounted) return;
    setState(() {
      _worlds = worlds;
      _loading = false;
    });
  }

  Future<void> _addWorld() async {
    final name = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عالم جديد'),
        content: TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم العالم')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('إضافة')),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    await context.read<AppState>().createWorld(name: name.text.trim());
    await _load();
  }

  Future<void> _deleteWorld(WorldModel world) async {
    await context.read<AppState>().deleteWorld(world.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlamoAppBar(
        title: const Text('العوالم'),
        actions: [IconButton(onPressed: _addWorld, icon: const Icon(Icons.add))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _worlds.length,
                itemBuilder: (context, index) {
                  final world = _worlds[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlayfulCard(
                      accent: AppTheme.grass,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(world.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('${world.itemsCount ?? 0} كلمة • ترتيب ${world.sortOrder}'),
                        trailing: IconButton(
                          onPressed: () => _deleteWorld(world),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
