import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/screens/auditory_discrimination_screen.dart';
import 'package:klamo_mobile/screens/auth_screen.dart';
import 'package:klamo_mobile/screens/create_child_screen.dart';
import 'package:klamo_mobile/screens/home_screen.dart';
import 'package:klamo_mobile/screens/pronunciation_screen.dart';
import 'package:klamo_mobile/screens/progress_screen.dart';
import 'package:klamo_mobile/screens/rewards_screen.dart';
import 'package:klamo_mobile/screens/specialist/specialist_child_detail_screen.dart';
import 'package:klamo_mobile/screens/specialist/specialist_child_form_screen.dart';
import 'package:klamo_mobile/screens/specialist/specialist_content_activities_screen.dart';
import 'package:klamo_mobile/screens/specialist/specialist_content_items_screen.dart';
import 'package:klamo_mobile/screens/specialist/specialist_content_worlds_screen.dart';
import 'package:klamo_mobile/screens/specialist/specialist_recording_review_screen.dart';
import 'package:klamo_mobile/screens/specialist/specialist_reports_screen.dart';
import 'package:klamo_mobile/screens/specialist/specialist_shell_screen.dart';
import 'package:klamo_mobile/screens/specialist/specialist_users_screen.dart';
import 'package:klamo_mobile/screens/splash_screen.dart';
import 'package:klamo_mobile/screens/word_recognition_screen.dart';
import 'package:klamo_mobile/screens/world_screen.dart';

class AppRouter {
  static GoRouter router(AppState appState) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: appState,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final loggedIn = appState.token != null;
        final hasChild = appState.selectedChild != null;
        final isSpecialist = appState.isSpecialist;

        if (location == '/splash') return null;
        if (!loggedIn && location != '/auth') return '/auth';

        if (loggedIn && isSpecialist) {
          final allowed = location.startsWith('/specialist') ||
              location == '/progress' ||
              location == '/auth';
          if (!allowed) return '/specialist';
          return null;
        }

        if (loggedIn && !hasChild && !location.startsWith('/create-child') && location != '/auth') {
          return '/auth';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (_, __) => const AuthScreen(),
        ),
        GoRoute(
          path: '/create-child',
          builder: (_, __) => const CreateChildScreen(),
        ),
        GoRoute(
          path: '/specialist',
          builder: (_, __) => const SpecialistShellScreen(),
          routes: [
            GoRoute(
              path: 'reports',
              builder: (_, __) => const SpecialistReportsScreen(),
            ),
            GoRoute(
              path: 'child/new',
              builder: (_, __) => const SpecialistChildFormScreen(),
            ),
            GoRoute(
              path: 'child/:id',
              builder: (_, state) => SpecialistChildDetailScreen(
                childId: int.parse(state.pathParameters['id']!),
              ),
            ),
            GoRoute(
              path: 'child/:id/edit',
              builder: (_, state) => SpecialistChildFormScreen(
                childId: int.parse(state.pathParameters['id']!),
              ),
            ),
            GoRoute(
              path: 'recording/:id',
              builder: (_, state) => SpecialistRecordingReviewScreen(
                attempt: state.extra as AttemptListItemModel,
              ),
            ),
            GoRoute(
              path: 'content/worlds',
              builder: (_, __) => const SpecialistContentWorldsScreen(),
            ),
            GoRoute(
              path: 'content/items',
              builder: (_, __) => const SpecialistContentItemsScreen(),
            ),
            GoRoute(
              path: 'content/activities',
              builder: (_, __) => const SpecialistContentActivitiesScreen(),
            ),
            GoRoute(
              path: 'users',
              builder: (_, __) => const SpecialistUsersScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/world/:id',
          builder: (context, state) => WorldScreen(
            worldId: int.parse(state.pathParameters['id']!),
            worldName: state.extra as String? ?? 'العالم',
          ),
        ),
        GoRoute(
          path: '/activity/word/:id',
          builder: (_, state) => WordRecognitionScreen(
            activityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/activity/auditory/:id',
          builder: (_, state) => AuditoryDiscriminationScreen(
            activityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/activity/pronunciation/:id',
          builder: (_, state) => PronunciationScreen(
            activityId: int.parse(state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/rewards',
          builder: (_, state) {
            final extra = state.extra;

            if (extra is AttemptResultModel) {
              return RewardsScreen(result: extra);
            }

            return RewardsScreen(stars: extra as int? ?? 1);
          },
        ),
        GoRoute(
          path: '/progress',
          builder: (_, __) => const ProgressScreen(),
        ),
      ],
    );
  }
}
