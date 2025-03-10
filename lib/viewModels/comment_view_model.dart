import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/models/comment_model.dart';

class CommentViewModel with ChangeNotifier {
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  String _errorMessage = "";

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchComments(String postId) async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    await Future.delayed(Duration(seconds: 2));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await ApiService.httpClient.get(
        Uri.parse('${ApiService.baseUrl}/comments/$postId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print(response.body);
        List<CommentModel> fetchedComments =
            (json.decode(response.body) as List)
                .map((comment) => CommentModel.fromJson(comment))
                .toList();
        _comments = fetchedComments;
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

  Future<void> addComment(int postId, String text) async {
    _errorMessage = "";
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await ApiService.httpClient.post(
        Uri.parse('${ApiService.baseUrl}/comments/$postId'),
        headers: {'Authorization': 'Bearer $token'},
        body: {"text": text},
      );

      print(json.encode({'postId': postId, 'text': text}));
      if (response.statusCode == 403) {
        _errorMessage = 'Unauthorized';
      } else if (response.statusCode != 200) {
        _errorMessage = "Failed to add Comment";
      }
    } catch (e) {
      throw e;
    } finally {
      notifyListeners();
    }
  }

  Future<void> addReply(int commentId, String content) async {
    _errorMessage = "";
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await ApiService.httpClient.post(
        Uri.parse('${ApiService.baseUrl}/replies/$commentId'),
        headers: {'Authorization': 'Bearer $token'},
        body: {"content": content},
      );

      if (response.statusCode == 403) {
        _errorMessage = 'Unauthorized';
      } else if (response.statusCode != 200) {
        _errorMessage = "Failed to add Reply";
      }
    } catch (e) {
      throw e;
    } finally {
      notifyListeners();
    }
  }
}
