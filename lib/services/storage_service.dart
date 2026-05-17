import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_userKey, user.toString());
  }

  Map<String, dynamic>? getUser() {
    final userString = _prefs.getString(_userKey);
    if (userString != null) {
      return Map<String, dynamic>.from(userString as Map);
    }
    return null;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}