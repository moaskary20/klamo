import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/gradient_button.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class CreateChildScreen extends StatefulWidget {
  const CreateChildScreen({super.key});

  @override
  State<CreateChildScreen> createState() => _CreateChildScreenState();
}

class _CreateChildScreenState extends State<CreateChildScreen> {
  final _nameController = TextEditingController();
  int _age = 5;
  String _gender = 'male';
  int _level = 1;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final child = await context.read<AppState>().createChild(
          name: _nameController.text.trim(),
          age: _age,
          gender: _gender,
          level: _level,
        );

    if (!mounted) return;

    if (child != null) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppState>().error ?? 'فشل الإنشاء')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AppState>().isLoading;

    return Scaffold(
      appBar: const KlamoAppBar(title: Text('إنشاء ملف طفل 🌟')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: PlayfulCard(
          accent: AppTheme.orange,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم الطفل'),
              ),
              const SizedBox(height: 20),
              Text('العمر: $_age سنوات', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _age.toDouble(),
                min: 5,
                max: 6,
                divisions: 1,
                activeColor: AppTheme.teal,
                label: '$_age',
                onChanged: (value) => setState(() => _age = value.toInt()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'الجنس'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('ذكر')),
                  DropdownMenuItem(value: 'female', child: Text('أنثى')),
                ],
                onChanged: (value) => setState(() => _gender = value ?? 'male'),
              ),
              const SizedBox(height: 20),
              Text('المستوى الحالي: $_level', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _level.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: AppTheme.purple,
                label: '$_level',
                onChanged: (value) => setState(() => _level = value.toInt()),
              ),
              const SizedBox(height: 12),
              Container(
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.skyLight, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face, size: 48, color: AppTheme.orange),
                    Text('صورة رمزية'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GradientButton(
                width: double.infinity,
                onPressed: loading ? null : _submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('حفظ وبدء التعلّم'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
