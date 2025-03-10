import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';

class AddPostViewModel with ChangeNotifier {
  File? _selectedImage;
  String _caption = '';
  bool _isSuccess = false;
  bool _isLoading = false;
  String _errorMessage = '';

  File? get selectedImage => _selectedImage;
  String get caption => _caption;
  bool get isSuccess => _isSuccess;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _selectedImage = File(pickedImage.path);
      notifyListeners();
    }
  }

  // testing purpose
  set selectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void updateCaption(String newCaption) {
    _caption = newCaption;
    notifyListeners();
  }

  Future<void> addPost(String caption, File image) async {
    print('Adding post: $_caption');
    print('Image path: ${_selectedImage?.path}');

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    if (_caption == '' || _selectedImage == null) {
      _errorMessage = 'Please fill in all fields';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('${ApiService.baseUrl}/posts');
      final request =
          http.MultipartRequest('POST', url)
            ..fields['caption'] = caption
            ..files.add(
              http.MultipartFile(
                'image',
                image.readAsBytes().asStream(),
                image.lengthSync(),
                filename: image.path.split('/').last,
              ),
            )
            ..headers['Authorization'] = 'Bearer $token';
      final response = await ApiService.httpClient.send(request);
      if (response.statusCode == 200) {
        _isSuccess = true;
      } else if (response.statusCode == 403) {
        _errorMessage = 'Unauthorized';
      } else {
        _errorMessage = 'Failed to add post';
      }
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
