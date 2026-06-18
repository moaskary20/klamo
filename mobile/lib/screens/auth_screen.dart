import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/child_avatar.dart';
import 'package:klamo_mobile/widgets/gradient_button.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  final _registerName = TextEditingController();
  final _registerEmail = TextEditingController();
  final _registerPassword = TextEditingController();
  String _role = 'parent';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _registerName.dispose();
    _registerEmail.dispose();
    _registerPassword.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final appState = context.read<AppState>();
    final ok = await appState.login(
      _loginEmail.text.trim(),
      _loginPassword.text,
    );

    if (!mounted) return;

    if (ok) {
      if (appState.isSpecialist) {
        context.go('/specialist');
      } else {
        _showChildSelection();
      }
    } else {
      _showError(appState.error);
    }
  }

  Future<void> _register() async {
    final appState = context.read<AppState>();
    final ok = await appState.register(
      name: _registerName.text.trim(),
      email: _registerEmail.text.trim(),
      password: _registerPassword.text,
      role: _role,
    );

    if (!mounted) return;

    if (ok) {
      if (appState.isSpecialist) {
        context.go('/specialist');
      } else {
        _showChildSelection();
      }
    } else {
      _showError(appState.error);
    }
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'حدث خطأ')),
    );
  }

  void _showChildSelection() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<AppState>(
          builder: (context, appState, _) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'اختر طفلاً',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (appState.children.isEmpty)
                    const Text(
                      'لا يوجد أطفال مسجّلون بعد. أضف طفلاً جديداً.',
                      textAlign: TextAlign.center,
                    ),
                  ...appState.children.map(_childTile),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/create-child');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة طفل جديد'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _childTile(ChildModel child) {
    return ListTile(
      leading: ChildAvatar(name: child.name, imageUrl: child.avatar, size: 48),
      title: Text(child.name),
      subtitle: Text('المستوى ${child.level} • ${child.age} سنوات'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        await context.read<AppState>().selectChild(child);
        if (context.mounted) {
          Navigator.pop(context);
          context.go('/home');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: const KlamoAppBar(title: Text('مرحباً في كلامو ✨')),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'تسجيل الدخول'),
              Tab(text: 'إنشاء حساب'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _loginForm(appState),
                _registerForm(appState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm(AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: PlayfulCard(
        accent: AppTheme.teal,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _loginEmail,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _loginPassword,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            GradientButton(
              width: double.infinity,
              onPressed: appState.isLoading ? null : _login,
              child: appState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('دخول ولي الأمر / الأخصائي'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerForm(AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: PlayfulCard(
        accent: AppTheme.purple,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _registerName,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _registerEmail,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _registerPassword,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'نوع الحساب'),
              items: const [
                DropdownMenuItem(value: 'parent', child: Text('ولي أمر')),
                DropdownMenuItem(value: 'specialist', child: Text('أخصائي')),
              ],
              onChanged: (value) => setState(() => _role = value ?? 'parent'),
            ),
            const SizedBox(height: 24),
            GradientButton(
              width: double.infinity,
              onPressed: appState.isLoading ? null : _register,
              child: appState.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('إنشاء حساب'),
            ),
          ],
        ),
      ),
    );
  }
}
