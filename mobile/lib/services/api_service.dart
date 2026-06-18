import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:klamo_mobile/core/constants/api_constants.dart';
import 'package:klamo_mobile/models/models.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final dynamic errors;

  @override
  String toString() => message;
}

class ApiService {
  static const _requestTimeout = Duration(seconds: 15);

  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<http.Response> _get(Uri uri) {
    return http.get(uri, headers: _headers).timeout(_requestTimeout);
  }

  Future<http.Response> _post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return http
        .post(
          uri,
          headers: headers ?? _headers,
          body: body,
        )
        .timeout(_requestTimeout);
  }

  Future<http.Response> _patch(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return http
        .patch(
          uri,
          headers: headers ?? _headers,
          body: body,
        )
        .timeout(_requestTimeout);
  }

  Future<http.Response> _delete(Uri uri) {
    return http.delete(uri, headers: _headers).timeout(_requestTimeout);
  }

  Future<http.Response> _sendMultipart(
    http.MultipartRequest request, {
    Duration? timeout,
  }) async {
    final streamed = await request.send().timeout(timeout ?? _requestTimeout);
    return http.Response.fromStream(streamed);
  }

  Future<Map<String, dynamic>> _decode(http.Response response) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      body['message'] as String? ?? 'حدث خطأ غير متوقع',
      statusCode: response.statusCode,
      errors: body['errors'],
    );
  }

  Future<BootstrapModel> bootstrap({String? token}) async {
    if (token != null) _token = token;

    final response = await _get(Uri.parse('${ApiConstants.baseUrl}/bootstrap'));
    final body = await _decode(response);
    return BootstrapModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _post(
      Uri.parse('${ApiConstants.baseUrl}/auth/register'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      }),
    );

    return _decode(response);
  }

  Future<List<ChildModel>> getChildren() async {
    final response = await _get(Uri.parse('${ApiConstants.baseUrl}/children'));
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['children'] as List<dynamic>)
        .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChildModel> createChild({
    required String name,
    required int age,
    required String gender,
    required int level,
    File? avatar,
    int? parentUserId,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/children'),
    );

    request.headers.addAll(_headers);
    request.fields.addAll({
      'name': name,
      'age': '$age',
      'gender': gender,
      'level': '$level',
    });

    if (parentUserId != null) {
      request.fields['user_id'] = '$parentUserId';
    }

    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
    }

    final response = await _sendMultipart(request);
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return ChildModel.fromJson(data['child'] as Map<String, dynamic>);
  }

  Future<ChildModel> updateChild({
    required int childId,
    String? name,
    int? age,
    String? gender,
    int? level,
    int? parentUserId,
    File? avatar,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/children/$childId'),
    );

    request.headers.addAll(_headers);
    request.fields['_method'] = 'PATCH';

    if (name != null) request.fields['name'] = name;
    if (age != null) request.fields['age'] = '$age';
    if (gender != null) request.fields['gender'] = gender;
    if (level != null) request.fields['level'] = '$level';
    if (parentUserId != null) request.fields['user_id'] = '$parentUserId';

    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
    }

    final response = await _sendMultipart(request);
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return ChildModel.fromJson(data['child'] as Map<String, dynamic>);
  }

  Future<void> deleteChild(int childId) async {
    final response = await _delete(Uri.parse('${ApiConstants.baseUrl}/children/$childId'));
    await _decode(response);
  }

  Future<DashboardStatsModel> getDashboardStats() async {
    final response = await _get(Uri.parse('${ApiConstants.baseUrl}/dashboard/stats'));
    final body = await _decode(response);
    return DashboardStatsModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<RecentSessionModel>> getRecentSessions({int limit = 10}) async {
    final response = await _get(
      Uri.parse('${ApiConstants.baseUrl}/dashboard/recent-sessions?limit=$limit'),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['sessions'] as List<dynamic>)
        .map((e) => RecentSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChildReportModel>> getChildReports() async {
    final response = await _get(Uri.parse('${ApiConstants.baseUrl}/children/reports'));
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['reports'] as List<dynamic>)
        .map((e) => ChildReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttemptListItemModel>> getAttempts({
    bool? hasAudio,
    int? childId,
    String? aiAnalysisStatus,
    int page = 1,
  }) async {
    final params = <String, String>{'page': '$page'};
    if (hasAudio == true) params['has_audio'] = '1';
    if (childId != null) params['child_id'] = '$childId';
    if (aiAnalysisStatus != null) params['ai_analysis_status'] = aiAnalysisStatus;

    final uri = Uri.parse('${ApiConstants.baseUrl}/attempts')
        .replace(queryParameters: params);
    final response = await _get(uri);
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['attempts'] as List<dynamic>)
        .map((e) => AttemptListItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttemptListItemModel> updateAttemptAnalysis({
    required int attemptId,
    required String analysisText,
  }) async {
    final response = await _patch(
      Uri.parse('${ApiConstants.baseUrl}/attempts/$attemptId/analysis'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'analysis_text': analysisText}),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return AttemptListItemModel.fromJson(data['attempt'] as Map<String, dynamic>);
  }

  Future<ContentStatsModel> getContentStats() async {
    final response = await _get(Uri.parse('${ApiConstants.baseUrl}/admin/content/stats'));
    final body = await _decode(response);
    return ContentStatsModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<WorldModel>> getAdminWorlds() async {
    final response = await _get(Uri.parse('${ApiConstants.baseUrl}/admin/content/worlds'));
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['worlds'] as List<dynamic>)
        .map((e) => WorldModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorldModel> createWorld({required String name, int sortOrder = 0}) async {
    final response = await _post(
      Uri.parse('${ApiConstants.baseUrl}/admin/worlds'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'sort_order': sortOrder}),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;
    return WorldModel.fromJson(data['world'] as Map<String, dynamic>);
  }

  Future<void> deleteWorld(int worldId) async {
    final response = await _delete(Uri.parse('${ApiConstants.baseUrl}/admin/worlds/$worldId'));
    await _decode(response);
  }

  Future<List<AdminItemModel>> getAdminItems({int? worldId}) async {
    final uri = worldId != null
        ? Uri.parse('${ApiConstants.baseUrl}/admin/items?world_id=$worldId')
        : Uri.parse('${ApiConstants.baseUrl}/admin/items');
    final response = await _get(uri);
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['items'] as List<dynamic>)
        .map((e) => AdminItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminItemModel> createItem({
    required int worldId,
    required String wordName,
    int minLevel = 1,
  }) async {
    final response = await _post(
      Uri.parse('${ApiConstants.baseUrl}/admin/items'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'world_id': worldId,
        'word_name': wordName,
        'min_level': minLevel,
      }),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;
    return AdminItemModel.fromJson(data['item'] as Map<String, dynamic>);
  }

  Future<void> deleteItem(int itemId) async {
    final response = await _delete(Uri.parse('${ApiConstants.baseUrl}/admin/items/$itemId'));
    await _decode(response);
  }

  Future<List<AdminActivityModel>> getAdminActivities({int? itemId}) async {
    final uri = itemId != null
        ? Uri.parse('${ApiConstants.baseUrl}/admin/activities?item_id=$itemId')
        : Uri.parse('${ApiConstants.baseUrl}/admin/activities');
    final response = await _get(uri);
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['activities'] as List<dynamic>)
        .map((e) => AdminActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminActivityModel> createActivity({
    required int itemId,
    required String type,
  }) async {
    final response = await _post(
      Uri.parse('${ApiConstants.baseUrl}/admin/activities'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'item_id': itemId, 'type': type}),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;
    return AdminActivityModel.fromJson(data['activity'] as Map<String, dynamic>);
  }

  Future<void> deleteActivity(int activityId) async {
    final response =
        await _delete(Uri.parse('${ApiConstants.baseUrl}/admin/activities/$activityId'));
    await _decode(response);
  }

  Future<List<ParentSummary>> getParents() async {
    final response = await _get(Uri.parse('${ApiConstants.baseUrl}/admin/users/parents'));
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['parents'] as List<dynamic>)
        .map((e) => ParentSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AdminUserModel>> getUsers({String? role}) async {
    final uri = role != null
        ? Uri.parse('${ApiConstants.baseUrl}/admin/users?role=$role')
        : Uri.parse('${ApiConstants.baseUrl}/admin/users');
    final response = await _get(uri);
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['users'] as List<dynamic>)
        .map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminUserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _post(
      Uri.parse('${ApiConstants.baseUrl}/admin/users'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;
    return AdminUserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> deleteUser(int userId) async {
    final response = await _delete(Uri.parse('${ApiConstants.baseUrl}/admin/users/$userId'));
    await _decode(response);
  }

  Future<List<WorldModel>> getWorlds(int childId) async {
    final response = await _get(
      Uri.parse('${ApiConstants.baseUrl}/worlds?child_id=$childId'),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return (data['worlds'] as List<dynamic>)
        .map((e) => WorldModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorldModel> getWorld(int worldId, int childId) async {
    final response = await _get(
      Uri.parse('${ApiConstants.baseUrl}/worlds/$worldId?child_id=$childId'),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;
    final worldJson = data['world'] as Map<String, dynamic>;

    return WorldModel.fromJson(worldJson);
  }

  Future<List<ItemModel>> getWorldItems(int worldId, int childId) async {
    final response = await _get(
      Uri.parse('${ApiConstants.baseUrl}/worlds/$worldId?child_id=$childId'),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;
    final worldJson = data['world'] as Map<String, dynamic>;

    return (worldJson['items'] as List<dynamic>? ?? [])
        .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ActivitySessionModel> getActivity(int activityId, int childId) async {
    final response = await _get(
      Uri.parse(
        '${ApiConstants.baseUrl}/activities/$activityId?child_id=$childId',
      ),
    );
    final body = await _decode(response);

    return ActivitySessionModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<AttemptResultModel> submitAttempt({
    required int childId,
    required int activityId,
    int? starsEarned,
    File? audio,
    bool isCompleted = true,
    bool analyzeSync = false,
    String? transcription,
    String? failureMessage,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/attempts'),
    );

    request.headers.addAll(_headers);
    request.fields.addAll({
      'child_id': '$childId',
      'activity_id': '$activityId',
      'is_completed': isCompleted ? '1' : '0',
    });

    if (starsEarned != null) {
      request.fields['stars_earned'] = '$starsEarned';
    }

    if (analyzeSync) {
      request.fields['analyze_sync'] = '1';
    }

    if (transcription != null && transcription.trim().isNotEmpty) {
      request.fields['transcription'] = transcription.trim();
    }

    if (failureMessage != null && failureMessage.trim().isNotEmpty) {
      request.fields['failure_message'] = failureMessage.trim();
    }

    if (audio != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audio.path,
          filename: audio.path.split(Platform.pathSeparator).last,
        ),
      );
    }

    final response = await _sendMultipart(
      request,
      timeout: analyzeSync ? const Duration(seconds: 90) : null,
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return AttemptResultModel.fromJson(data['attempt'] as Map<String, dynamic>);
  }

  Future<ProgressModel> getProgress(int childId) async {
    final response = await _get(
      Uri.parse('${ApiConstants.baseUrl}/children/$childId/progress'),
    );
    final body = await _decode(response);
    final data = body['data'] as Map<String, dynamic>;

    return ProgressModel.fromJson(data['progress'] as Map<String, dynamic>);
  }
}
