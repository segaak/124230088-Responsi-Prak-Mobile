import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String userBoxName = 'users';
  static const String sessionKey = 'logged_in_user';

   Future<bool> register({
    required String username,
    required String password,
  }) async {
    try {
      
      final box = await Hive.openBox<UserModel>(userBoxName);

      final existingUser = box.values.firstWhere(
        (user) => user.username == username,
        orElse: () => UserModel(username: '', password: ''),
      );

      if (existingUser.username.isNotEmpty) {
        return false;
      }
      final newUser = UserModel(
        username: username,
        password: password,
      );

      await box.add(newUser);
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<UserModel?> login(String username, String password) async {
    try {
      final box = await Hive.openBox<UserModel>(userBoxName);

      final user = box.values.firstWhere(
        (user) => user.username == username && user.password == password,
        orElse: () => UserModel(username: '', password: ''),
      );

      if (user.username.isNotEmpty) {
        await saveSession(username);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
   Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionKey, username);
  }

  Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(sessionKey);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final box = await Hive.openBox<UserModel>(userBoxName);
      final user = box.values.firstWhere(
        (user) => user.username == username,
        orElse: () => UserModel(username: '', password: ''),
      );
      return user.username.isNotEmpty ? user : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionKey);
  }

  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null && session.isNotEmpty;
  }
}