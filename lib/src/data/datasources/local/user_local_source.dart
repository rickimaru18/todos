import 'dart:async';

import 'package:hive/hive.dart';

import '../../models/user_model.dart';
import 'local_source.dart';

class UserLocalSource extends LocalSource {
  factory UserLocalSource() => _instance;

  UserLocalSource._();

  static final UserLocalSource _instance = UserLocalSource._();

  late final LazyBox<UserSignupModel> _users;
  late final LazyBox<String> _loggedInUser;

  @override
  void registerAdapters() {
    Hive.registerAdapter<UserSignupModel>(UserSignupModelAdapter());
  }

  @override
  Future<void> openBoxes() async {
    _users = await Hive.openLazyBox<UserSignupModel>('users');
    _loggedInUser = await Hive.openLazyBox<String>('loggedInUser');
  }

  /// Get number of registered users.
  Future<int> userCount() async {
    await areBoxesOpen;
    return _users.length;
  }

  /// Check if user with [username] exist.
  Future<bool> hasUser(String username) async {
    await areBoxesOpen;
    return _users.containsKey(username);
  }

  /// Get user with [username] and [password].
  Future<UserSignupModel?> getUser(String username, String password) async {
    await areBoxesOpen;
    final UserSignupModel? userSignupModel = await _users.get(username);
    return userSignupModel?.password == password ? userSignupModel : null;
  }

  /// Add user with [username] and [password].
  Future<UserSignupModel> addUser(String username, String password) async {
    await areBoxesOpen;
    final UserSignupModel data = UserSignupModel(_users.length + 1, password);
    await _users.put(username, data);
    return data;
  }

  /// Get logged-in user.
  Future<Map<String, UserSignupModel>?> getLoggedInUser() async {
    await areBoxesOpen;
    final String? username =
        _loggedInUser.isNotEmpty ? await _loggedInUser.getAt(0) : null;
    return username != null
        ? <String, UserSignupModel>{username: (await _users.get(username))!}
        : null;
  }

  /// Login user with [username].
  Future<void> loginUser(String username) async {
    await areBoxesOpen;
    await _loggedInUser.add(username);
  }

  /// Logout user.
  ///
  /// User to logout is the last user that called [loginUser].
  Future<bool> logoutUser() async {
    await areBoxesOpen;

    if (_loggedInUser.isEmpty) {
      return false;
    }

    await _loggedInUser.clear();
    return true;
  }
}
