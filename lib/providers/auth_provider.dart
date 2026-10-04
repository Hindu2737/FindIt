import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String _name = '';
  String _studentId = '';
  String _email = '';
  String _password = '';
  bool _isLoggedIn = false;

  List<Map<String, String>> _accounts = [];

  String get name => _name;
  String get studentId => _studentId;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loadAccount() async {
    final prefs = await SharedPreferences.getInstance();

    final savedAccounts = prefs.getStringList('accounts');

    if (savedAccounts != null && savedAccounts.isNotEmpty) {
      _accounts = savedAccounts.map<Map<String, String>>((account) {
        final Map<String, dynamic> data =
            jsonDecode(account) as Map<String, dynamic>;

        return <String, String>{
          'name': data['name']?.toString() ?? '',
          'studentId': data['studentId']?.toString() ?? '',
          'email': data['email']?.toString() ?? '',
          'password': data['password']?.toString() ?? '',
        };
      }).toList();
    } else {
      // Migrate old single-account data.
      final oldEmail = prefs.getString('email');

      if (oldEmail != null && oldEmail.isNotEmpty) {
        final oldAccount = <String, String>{
          'name': prefs.getString('name') ?? '',
          'studentId': prefs.getString('studentId') ?? '',
          'email': oldEmail,
          'password': prefs.getString('password') ?? '',
        };

        _accounts = [oldAccount];

        await _saveAccounts();
      }
    }

    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn) {
      final loggedInEmail = prefs.getString('email') ?? '';

      final account = _findAccount(loggedInEmail);

      if (account != null) {
        _setCurrentUser(account);
      } else {
        _isLoggedIn = false;
      }
    } else {
      _name = prefs.getString('name') ?? '';
      _studentId = prefs.getString('studentId') ?? '';
      _email = prefs.getString('email') ?? '';
      _password = prefs.getString('password') ?? '';
    }

    notifyListeners();
  }

  Future<bool> createAccount({
    required String name,
    required String studentId,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_findAccount(normalizedEmail) != null) {
      return false;
    }

    final newAccount = <String, String>{
      'name': name.trim(),
      'studentId': studentId.trim(),
      'email': normalizedEmail,
      'password': password,
    };

    _accounts.add(newAccount);

    await _saveAccounts();

    return true;
  }

  bool login({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();

    final account = _findAccount(normalizedEmail);

    if (account == null) {
      return false;
    }

    if (account['password'] != password) {
      return false;
    }

    _setCurrentUser(account);

    _isLoggedIn = true;

    _saveCurrentSession();

    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', false);

    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_email.isEmpty) {
      return;
    }

    _accounts.removeWhere(
      (account) =>
          account['email']?.toLowerCase() == _email.toLowerCase(),
    );

    await _saveAccounts();

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('name');
    await prefs.remove('studentId');
    await prefs.remove('email');
    await prefs.remove('password');

    await prefs.setBool('isLoggedIn', false);

    _name = '';
    _studentId = '';
    _email = '';
    _password = '';
    _isLoggedIn = false;

    notifyListeners();
  }

  // ---------------------------------------------------------
  // GET USER NAME USING EMAIL
  // ---------------------------------------------------------

  String getUserNameByEmail(String email) {
    final account = _findAccount(email);

    if (account == null) {
      return email;
    }

    final userName = account['name'] ?? '';

    if (userName.isEmpty) {
      return email;
    }

    return userName;
  }

  // ---------------------------------------------------------
  // GET USER STUDENT ID USING EMAIL
  // ---------------------------------------------------------

  String getStudentIdByEmail(String email) {
    final account = _findAccount(email);

    if (account == null) {
      return '';
    }

    return account['studentId'] ?? '';
  }

  Map<String, String>? _findAccount(String email) {
    for (final account in _accounts) {
      if (account['email']?.toLowerCase() == email.toLowerCase()) {
        return account;
      }
    }

    return null;
  }

  void _setCurrentUser(Map<String, String> account) {
    _name = account['name'] ?? '';
    _studentId = account['studentId'] ?? '';
    _email = account['email'] ?? '';
    _password = account['password'] ?? '';
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();

    final savedAccounts = _accounts
        .map((account) => jsonEncode(account))
        .toList();

    await prefs.setStringList('accounts', savedAccounts);
  }

  Future<void> _saveCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', _name);
    await prefs.setString('studentId', _studentId);
    await prefs.setString('email', _email);
    await prefs.setString('password', _password);
    await prefs.setBool('isLoggedIn', _isLoggedIn);
  }
}