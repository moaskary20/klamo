import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/constants/api_constants.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/services/api_service.dart';
import 'package:klamo_mobile/services/storage_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    ApiService? apiService,
    StorageService? storageService,
  })  : _api = apiService ?? ApiService(),
        _storage = storageService ?? StorageService();

  final ApiService _api;
  final StorageService _storage;

  bool isLoading = false;
  String? error;
  String? token;
  UserModel? user;
  ChildModel? selectedChild;
  List<ChildModel> children = [];
  List<WorldModel> worlds = [];
  BootstrapModel? bootstrap;
  bool _bootstrapped = false;

  bool get isBootstrapped => _bootstrapped;

  bool get isSpecialist => user?.role == 'specialist';

  bool get isParent => user?.role == 'parent';

  /// Called when bootstrap is abandoned (e.g. startup timeout) so UI loading
  /// states are not left stuck while a background request may still be running.
  void abandonBootstrap() {
    isLoading = false;
    _bootstrapped = true;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_bootstrapped) return;

    error = null;

    try {
      token = await _storage.getToken();
      _api.setToken(token);
      bootstrap = await _api.bootstrap(token: token);

      if (bootstrap!.authenticated && bootstrap!.user != null) {
        user = bootstrap!.user;
        children = bootstrap!.children;
        worlds = bootstrap!.worlds;

        final savedChildId = await _storage.getSelectedChildId();
        if (savedChildId != null) {
          for (final child in children) {
            if (child.id == savedChildId) {
              selectedChild = child;
              break;
            }
          }
        }
      } else {
        worlds = bootstrap!.worlds;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      _bootstrapped = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    return _authenticate(() => _api.login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    return _authenticate(
      () => _api.register(
        name: name,
        email: email,
        password: password,
        role: role,
      ),
    );
  }

  Future<bool> _authenticate(Future<Map<String, dynamic>> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final body = await action();
      final data = body['data'] as Map<String, dynamic>;
      token = data['token'] as String;
      user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      await _storage.saveToken(token!);
      _api.setToken(token);
      children = await _api.getChildren();

      if (!isSpecialist && children.isNotEmpty) {
        worlds = await _api.getWorlds(children.first.id);
      }

      return true;
    } catch (e) {
      error = _connectionErrorMessage(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _connectionErrorMessage(Object error) {
    if (error is ApiException) return error.message;
    if (error is TimeoutException) {
      return 'انتهت مهلة الاتصال بالسيرفر (${ApiConstants.baseUrl}). '
          'تأكد أن السيرفر يعمل وأن عنوان API صحيح.';
    }
    if (error is SocketException) {
      if (ApiConstants.isProduction && !ApiConstants.isConfiguredForProduction) {
        return 'عنوان السيرفر غير مضبوط. عدّل kProductionApiBaseUrl في '
            'mobile/lib/core/config/api_env.dart ثم أعد بناء التطبيق.';
      }

      return 'تعذر الاتصال بالسيرفر (${ApiConstants.baseUrl}). '
          'تحقق من الإنترنت وعنوان API.';
    }
    return error.toString();
  }

  Future<void> refreshChildren() async {
    children = await _api.getChildren();
    notifyListeners();
  }

  Future<ChildModel?> createChild({
    required String name,
    required int age,
    required String gender,
    required int level,
    int? parentUserId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final child = await _api.createChild(
        name: name,
        age: age,
        gender: gender,
        level: level,
        parentUserId: parentUserId,
      );
      children = await _api.getChildren();
      if (!isSpecialist) {
        await selectChild(child);
      }
      return child;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectChild(ChildModel child) async {
    selectedChild = child;
    await _storage.saveSelectedChildId(child.id);
    worlds = await _api.getWorlds(child.id);
    notifyListeners();
  }

  Future<void> logout() async {
    token = null;
    user = null;
    selectedChild = null;
    children = [];
    await _storage.clearAll();
    _api.setToken(null);
    bootstrap = await _api.bootstrap();
    worlds = bootstrap!.worlds;
    notifyListeners();
  }

  Future<List<ItemModel>> loadWorldItems(int worldId) async {
    if (selectedChild == null) return [];
    return _api.getWorldItems(worldId, selectedChild!.id);
  }

  Future<ActivitySessionModel> loadActivity(int activityId) async {
    return _api.getActivity(activityId, selectedChild!.id);
  }

  Future<AttemptResultModel> submitAttempt({
    required int activityId,
    int? starsEarned,
    String? audioPath,
    bool analyzeSync = false,
    bool isCompleted = true,
    String? transcription,
    String? failureMessage,
  }) async {
    return _api.submitAttempt(
      childId: selectedChild!.id,
      activityId: activityId,
      starsEarned: starsEarned,
      audio: audioPath != null ? File(audioPath) : null,
      isCompleted: analyzeSync ? false : isCompleted,
      analyzeSync: analyzeSync,
      transcription: transcription,
      failureMessage: failureMessage,
    );
  }

  Future<AttemptResultModel> analyzePronunciation({
    required int activityId,
    required String audioPath,
    String? transcription,
  }) {
    return submitAttempt(
      activityId: activityId,
      audioPath: audioPath,
      analyzeSync: true,
      transcription: transcription,
    );
  }

  Future<ProgressModel> loadProgress() async {
    return _api.getProgress(selectedChild!.id);
  }

  ApiService get api => _api;

  Future<DashboardStatsModel> loadDashboardStats() => _api.getDashboardStats();

  Future<List<RecentSessionModel>> loadRecentSessions({int limit = 10}) =>
      _api.getRecentSessions(limit: limit);

  Future<List<ChildReportModel>> loadChildReports() => _api.getChildReports();

  Future<List<AttemptListItemModel>> loadAttempts({
    bool? hasAudio,
    int? childId,
    String? aiAnalysisStatus,
    int page = 1,
  }) =>
      _api.getAttempts(
        hasAudio: hasAudio,
        childId: childId,
        aiAnalysisStatus: aiAnalysisStatus,
        page: page,
      );

  Future<AttemptListItemModel> updateAttemptAnalysis({
    required int attemptId,
    required String analysisText,
  }) =>
      _api.updateAttemptAnalysis(attemptId: attemptId, analysisText: analysisText);

  Future<ContentStatsModel> loadContentStats() => _api.getContentStats();

  Future<List<WorldModel>> loadAdminWorlds() => _api.getAdminWorlds();

  Future<WorldModel> createWorld({required String name, int sortOrder = 0}) =>
      _api.createWorld(name: name, sortOrder: sortOrder);

  Future<void> deleteWorld(int worldId) => _api.deleteWorld(worldId);

  Future<List<AdminItemModel>> loadAdminItems({int? worldId}) =>
      _api.getAdminItems(worldId: worldId);

  Future<AdminItemModel> createItem({
    required int worldId,
    required String wordName,
    int minLevel = 1,
  }) =>
      _api.createItem(worldId: worldId, wordName: wordName, minLevel: minLevel);

  Future<void> deleteItem(int itemId) => _api.deleteItem(itemId);

  Future<List<AdminActivityModel>> loadAdminActivities({int? itemId}) =>
      _api.getAdminActivities(itemId: itemId);

  Future<AdminActivityModel> createActivity({
    required int itemId,
    required String type,
  }) =>
      _api.createActivity(itemId: itemId, type: type);

  Future<void> deleteActivity(int activityId) => _api.deleteActivity(activityId);

  Future<List<ParentSummary>> loadParents() => _api.getParents();

  Future<List<AdminUserModel>> loadUsers({String? role}) =>
      _api.getUsers(role: role);

  Future<AdminUserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) =>
      _api.createUser(
        name: name,
        email: email,
        password: password,
        role: role,
      );

  Future<void> deleteUser(int userId) => _api.deleteUser(userId);

  Future<ChildModel> updateChild({
    required int childId,
    String? name,
    int? age,
    String? gender,
    int? level,
    int? parentUserId,
  }) async {
    final child = await _api.updateChild(
      childId: childId,
      name: name,
      age: age,
      gender: gender,
      level: level,
      parentUserId: parentUserId,
    );
    children = await _api.getChildren();
    notifyListeners();
    return child;
  }

  Future<void> deleteChild(int childId) async {
    await _api.deleteChild(childId);
    children = await _api.getChildren();
    if (selectedChild?.id == childId) {
      selectedChild = null;
    }
    notifyListeners();
  }
}
