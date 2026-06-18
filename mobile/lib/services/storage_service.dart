import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _childIdKey = 'selected_child_id';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> saveSelectedChildId(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_childIdKey, childId);
  }

  Future<int?> getSelectedChildId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_childIdKey);
  }

  Future<void> clearSelectedChildId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_childIdKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_childIdKey);
  }
}
