import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistContentItemsScreen extends StatefulWidget {
  const SpecialistContentItemsScreen({super.key});

  @override
  State<SpecialistContentItemsScreen> createState() =>
      _SpecialistContentItemsScreenState();
}

class _SpecialistContentItemsScreenState extends State<SpecialistContentItemsScreen> {
  List<AdminItemModel> _items = [];
  List<WorldModel> _worlds = [];
  int? _worldId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appState = context.read<AppState>();
    final worlds = await appState.loadAdminWorlds();
    final items = await appState.loadAdminItems(worldId: _worldId);
    if (!mounted) return;
    setState(() {
      _worlds = worlds;
      _items = items;
      _loading = false;
    });
  }

  Future<void> _addItem() async {
    if (_worlds.isEmpty) return;

    final word = TextEditingController();
    var worldId = _worldId ?? _worlds.first.id;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('كلمة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: word, decoration: const InputDecoration(labelText: 'الكلمة')),
            DropdownButtonFormField<int>(
              initialValue: worldId,
              items: _worlds
                  .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                  .toList(),
              onChanged: (v) => worldId = v ?? worldId,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('إضافة')),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    await context.read<AppState>().createItem(worldId: worldId, wordName: word.text.trim());
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlamoAppBar(
        title: const Text('الكلمات'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: Column(
        children: [
          if (_worlds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<int?>(
                initialValue: _worldId,
                decoration: const InputDecoration(labelText: 'تصفية حسب العالم'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('كل العوالم')),
                  ..._worlds.map(
                    (w) => DropdownMenuItem(value: w.id, child: Text(w.name)),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    _worldId = v;
                    _loading = true;
                  });
                  _load();
                },
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PlayfulCard(
                            accent: AppTheme.orange,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item.wordName,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              subtitle: Text(
                                '${item.worldName ?? ''} • مستوى ${item.minLevel} • ${item.activities.length} نشاط',
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  await context.read<AppState>().deleteItem(item.id);
                                  await _load();
                                },
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
