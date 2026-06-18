import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/child_avatar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistChildrenTab extends StatefulWidget {
  const SpecialistChildrenTab({super.key});

  @override
  State<SpecialistChildrenTab> createState() => _SpecialistChildrenTabState();
}

class _SpecialistChildrenTabState extends State<SpecialistChildrenTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().refreshChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final children = appState.children;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'جميع الأطفال (${children.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.push('/specialist/child/new'),
                icon: const Icon(Icons.add),
                label: const Text('إضافة طفل'),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: appState.refreshChildren,
            child: children.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(child: Text('لا يوجد أطفال مسجّلون بعد.')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.push('/specialist/child/${child.id}'),
                            child: PlayfulCard(
                              accent: AppTheme.worldGradients[index % AppTheme.worldGradients.length]
                                  .colors
                                  .first,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: ChildAvatar(
                                  name: child.name,
                                  imageUrl: child.avatar,
                                  size: 52,
                                ),
                                title: Text(
                                  child.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(
                                  'المستوى ${child.level} • ${child.age} سنوات'
                                  '${child.parent != null ? ' • ولي الأمر: ${child.parent!.name}' : ''}',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${child.completedAttemptsCount} نشاط'),
                                    Text(
                                      '${child.averageStars.toStringAsFixed(1)} نجمة',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
