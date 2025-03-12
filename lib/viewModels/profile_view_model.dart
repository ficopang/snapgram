import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/models/profile_model.dart';

class ProfileViewModel with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = "";
  ProfileModel? _profile;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ProfileModel? get profile => _profile;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await ApiService.httpClient.get(
        Uri.parse('${ApiService.baseUrl}/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 403) {
        _errorMessage = 'Unauthorized';
      } else if (response.statusCode != 200) {
        _errorMessage = "Failed to like post";
      } else {
        final profileJSON = json.decode(response.body);
        print(profileJSON);
        _profile = ProfileModel.fromJson(profileJSON);
      }
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
