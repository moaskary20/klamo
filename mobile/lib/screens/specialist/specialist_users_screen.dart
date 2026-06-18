import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistUsersScreen extends StatefulWidget {
  const SpecialistUsersScreen({super.key});

  @override
  State<SpecialistUsersScreen> createState() => _SpecialistUsersScreenState();
}

class _SpecialistUsersScreenState extends State<SpecialistUsersScreen> {
  List<AdminUserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await context.read<AppState>().loadUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  Future<void> _createUser() async {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    var role = 'parent';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مستخدم جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم')),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'البريد')),
              TextField(
                controller: password,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: const [
                  DropdownMenuItem(value: 'parent', child: Text('ولي أمر')),
                  DropdownMenuItem(value: 'specialist', child: Text('أخصائي')),
                ],
                onChanged: (v) => role = v ?? 'parent',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('إنشاء')),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await context.read<AppState>().createUser(
          name: name.text.trim(),
          email: email.text.trim(),
          password: password.text,
          role: role,
        );
    await _load();
  }

  Future<void> _deleteUser(AdminUserModel user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف مستخدم'),
        content: Text('حذف ${user.name}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );

    if (ok != true || !mounted) return;
    await context.read<AppState>().deleteUser(user.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KlamoAppBar(
        title: const Text('المستخدمون'),
        actions: [
          IconButton(onPressed: _createUser, icon: const Icon(Icons.person_add)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlayfulCard(
                      accent: user.role == 'specialist' ? AppTheme.purple : AppTheme.teal,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('${user.email} • ${user.roleLabel}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${user.childrenCount} طفل'),
                            IconButton(
                              onPressed: () => _deleteUser(user),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ],
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
