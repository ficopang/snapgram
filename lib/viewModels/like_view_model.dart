import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/models/like_model.dart';

class LikeViewModel with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = "";
  List<LikeModel> _likes = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<LikeModel> get likes => _likes;

  Future<void> fetchLikes() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await ApiService.httpClient.get(
        Uri.parse('${ApiService.baseUrl}/post/likes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print(response.body);
        List<LikeModel> fetchedLikes =
            (json.decode(response.body) as List)
                .map((like) => LikeModel.fromJson(like))
                .toList();
        _likes = fetchedLikes;
      } else if (response.statusCode == 403) {
        _errorMessage = 'Unauthorized';
      }
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
