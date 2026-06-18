import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistContentActivitiesScreen extends StatefulWidget {
  const SpecialistContentActivitiesScreen({super.key});

  @override
  State<SpecialistContentActivitiesScreen> createState() =>
      _SpecialistContentActivitiesScreenState();
}

class _SpecialistContentActivitiesScreenState extends State<SpecialistContentActivitiesScreen> {
  List<AdminActivityModel> _activities = [];
  List<AdminItemModel> _items = [];
  int? _itemId;
  bool _loading = true;

  static const _activityTypes = [
    ('word_recognition', 'التعرف على الكلمة'),
    ('auditory_discrimination', 'التمييز السمعي'),
    ('pronunciation_recording', 'تسجيل النطق'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appState = context.read<AppState>();
    final items = await appState.loadAdminItems();
    final activities = await appState.loadAdminActivities(itemId: _itemId);
    if (!mounted) return;
    setState(() {
      _items = items;
      _activities = activities;
      _loading = false;
    });
  }

  Future<void> _addActivity() async {
    if (_items.isEmpty) return;

    var itemId = _itemId ?? _items.first.id;
    var type = _activityTypes.first.$1;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نشاط جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: itemId,
              items: _items
                  .map((i) => DropdownMenuItem(value: i.id, child: Text(i.wordName)))
                  .toList(),
              onChanged: (v) => itemId = v ?? itemId,
            ),
            DropdownButtonFormField<String>(
              initialValue: type,
              items: _activityTypes
                  .map((t) => DropdownMenuItem(value: t.$1, child: Text(t.$2)))
                  .toList(),
              onChanged: (v) => type = v ?? type,
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
    await context.read<AppState>().createActivity(itemId: itemId, type: type);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlamoAppBar(
        title: const Text('الأنشطة'),
        actions: [IconButton(onPressed: _addActivity, icon: const Icon(Icons.add))],
      ),
      body: Column(
        children: [
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<int?>(
                initialValue: _itemId,
                decoration: const InputDecoration(labelText: 'تصفية حسب الكلمة'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('كل الكلمات')),
                  ..._items.map(
                    (i) => DropdownMenuItem(value: i.id, child: Text(i.wordName)),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    _itemId = v;
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
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PlayfulCard(
                            accent: AppTheme.teal,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                activity.typeLabel,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              subtitle: Text(
                                '${activity.wordName ?? ''} • ${activity.worldName ?? ''}',
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  await context.read<AppState>().deleteActivity(activity.id);
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
