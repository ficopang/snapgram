import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/models/user_login_model.dart';

class LoginViewModel with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _errorMessage = "";
  UserLoginModel? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  UserLoginModel? get user => _user;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final response = await ApiService.httpClient.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        body: json.encode({'username': username, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        _user = UserLoginModel.fromJson(user);

        // save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _user?.getToken);

        _isAuthenticated = true;
      } else if (response.statusCode == 403) {
        _errorMessage = 'Invalid username or password';
      }
    } catch (e) {
      _errorMessage = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isLoading = false;
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
