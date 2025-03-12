import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/models/post_model.dart';

class PostViewModel with ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String _errorMessage = "";

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    // await Future.delayed(Duration(seconds: 2));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await ApiService.httpClient.get(
        Uri.parse('${ApiService.baseUrl}/posts'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print(response.body);
        List<PostModel> fetchedPosts =
            (json.decode(response.body) as List)
                .map((post) => PostModel.fromJson(post))
                .toList();
        _posts = fetchedPosts;
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

  Future<void> deletePost(int postId) async {
    _errorMessage = "";
    print("called");
    // notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await ApiService.httpClient.delete(
        Uri.parse('${ApiService.baseUrl}/posts/$postId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("called");

      if (response.statusCode == 403) {
        _errorMessage = 'Unauthorized';
      } else if (response.statusCode != 200) {
        _errorMessage = "Failed to like post";
      } else {
        print(response.body);
      }
    } catch (e) {
      throw e;
    } finally {
      // notifyListeners();
    }
  }

  Future<void> likePost(String postId) async {
    _errorMessage = "";
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await ApiService.httpClient.post(
        Uri.parse('${ApiService.baseUrl}/post/$postId/like'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 403) {
        _errorMessage = 'Unauthorized';
      } else if (response.statusCode != 200) {
        _errorMessage = "Failed to like post";
      }
    } catch (e) {
      throw e;
    } finally {
      notifyListeners();
    }
  }
}
