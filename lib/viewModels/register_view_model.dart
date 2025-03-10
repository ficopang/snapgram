import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/models/user_register_model.dart';

class RegisterViewModel with ChangeNotifier {
  bool _isSuccess = false;
  String _errorMessage = '';
  bool _isLoading = false;
  UserRegisterModel? _user;

  bool get isSuccess => _isSuccess;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  UserRegisterModel? get user => _user;

  Future<void> register(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    _isSuccess = false;
    notifyListeners();

    try {
      final response = await ApiService.httpClient.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        body: json.encode({'username': username, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        _user = UserRegisterModel.fromJson(user);
        _isSuccess = true;
      } else {
        _errorMessage = 'Failed to register';
      }
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
