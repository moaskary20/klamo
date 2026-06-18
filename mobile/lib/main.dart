import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/router/app_router.dart';
import 'package:klamo_mobile/widgets/sky_background.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();

  try {
    await appState
        .initialize()
        .timeout(const Duration(seconds: 10));
  } catch (_) {
    // Continue to splash even if bootstrap fails or times out.
    appState.abandonBootstrap();
  }

  runApp(KlamoApp(appState: appState));
}

class KlamoApp extends StatefulWidget {
  const KlamoApp({super.key, required this.appState});

  final AppState appState;

  @override
  State<KlamoApp> createState() => _KlamoAppState();
}

class _KlamoAppState extends State<KlamoApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(widget.appState);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.appState,
      child: MaterialApp.router(
        title: 'كلامو',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('ar'),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SkyBackground(
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        routerConfig: _router,
      ),
    );
  }
}
