import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/gradient_button.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistChildFormScreen extends StatefulWidget {
  const SpecialistChildFormScreen({super.key, this.childId});

  final int? childId;

  @override
  State<SpecialistChildFormScreen> createState() => _SpecialistChildFormScreenState();
}

class _SpecialistChildFormScreenState extends State<SpecialistChildFormScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController(text: '5');
  final _level = TextEditingController(text: '1');
  String _gender = 'male';
  int? _parentId;
  List<ParentSummary> _parents = [];
  bool _loading = false;
  bool _loadingParents = true;

  bool get isEditing => widget.childId != null;

  @override
  void initState() {
    super.initState();
    _loadParents();
    if (isEditing) _loadChild();
  }

  Future<void> _loadParents() async {
    try {
      final parents = await context.read<AppState>().loadParents();
      if (!mounted) return;
      setState(() {
        _parents = parents;
        _loadingParents = false;
        if (_parentId == null && parents.isNotEmpty) {
          _parentId = parents.first.id;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingParents = false);
    }
  }

  void _loadChild() {
    final child = context
        .read<AppState>()
        .children
        .where((c) => c.id == widget.childId)
        .firstOrNull;
    if (child == null) return;

    _name.text = child.name;
    _age.text = '${child.age}';
    _level.text = '${child.level}';
    _gender = child.gender;
    _parentId = child.parent?.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _level.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_parentId == null && !isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر ولي أمر للطفل')),
      );
      return;
    }

    setState(() => _loading = true);
    final appState = context.read<AppState>();

    try {
      if (isEditing) {
        await appState.updateChild(
          childId: widget.childId!,
          name: _name.text.trim(),
          age: int.parse(_age.text),
          gender: _gender,
          level: int.parse(_level.text),
          parentUserId: _parentId,
        );
      } else {
        await appState.createChild(
          name: _name.text.trim(),
          age: int.parse(_age.text),
          gender: _gender,
          level: int.parse(_level.text),
          parentUserId: _parentId,
        );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlamoAppBar(
        title: Text(isEditing ? 'تعديل طفل' : 'إضافة طفل'),
      ),
      body: _loadingParents
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: PlayfulCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'اسم الطفل'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _age,
                      decoration: const InputDecoration(labelText: 'العمر'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _level,
                      decoration: const InputDecoration(labelText: 'المستوى'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: 'الجنس'),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('ذكر')),
                        DropdownMenuItem(value: 'female', child: Text('أنثى')),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? 'male'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _parentId,
                      decoration: const InputDecoration(labelText: 'ولي الأمر'),
                      items: _parents
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _parentId = v),
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      width: double.infinity,
                      onPressed: _loading ? null : _save,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditing ? 'حفظ التعديلات' : 'إنشاء الطفل'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
