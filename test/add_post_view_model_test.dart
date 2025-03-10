import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/viewModels/add_post_view_model.dart';

import 'add_post_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('AddPostViewModel', () {
    late AddPostViewModel viewModel;
    late MockClient mockClient;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockClient = MockClient();
      ApiService.setHttpClient(mockClient);
      viewModel = AddPostViewModel();
      SharedPreferences.setMockInitialValues({});
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString('token', 'mockToken');
    });

    tearDown(() {
      reset(mockClient);
    });

    test('updateCaption should update caption', () {
      viewModel.updateCaption('Test Caption');
      expect(viewModel.caption, 'Test Caption');
    });

    test('addPost should set errorMessage on empty fields', () async {
      await viewModel.addPost('', File('test_image.jpg'));
      expect(viewModel.errorMessage, 'Please fill in all fields');
      expect(viewModel.isLoading, false);
    });

    test('addPost should handle successful post', () async {
      final file = File('test_image.jpg');
      await file.create(); // Create file

      final mockResponse = http.StreamedResponse(
        Stream.value(utf8.encode('')),
        200,
      );

      when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

      viewModel.updateCaption('Test Caption');
      viewModel.selectedImage = file;

      await viewModel.addPost(viewModel.caption, file);

      expect(viewModel.isSuccess, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, '');
    });

    test('addPost should set errorMessage on unauthorized post', () async {
      final file = File('test_image.jpg');
      await file.create();

      final mockResponse = http.StreamedResponse(
        Stream.value(utf8.encode('')),
        403,
      );

      when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

      viewModel.updateCaption('Test Caption');
      viewModel.selectedImage = file;

      await viewModel.addPost(viewModel.caption, file);

      expect(viewModel.isSuccess, false);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, 'Unauthorized');
    });

    test('addPost should set errorMessage on failed post', () async {
      final file = File('test_image.jpg');
      await file.create();

      final mockResponse = http.StreamedResponse(
        Stream.value(utf8.encode('')),
        500,
      );

      when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

      viewModel.updateCaption('Test Caption');
      viewModel.selectedImage = file;

      await viewModel.addPost(viewModel.caption, file);

      expect(viewModel.isSuccess, false);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, 'Failed to add post');
    });

    test('addPost should handle exceptions', () async {
      final file = File('test_image.jpg');
      await file.create();

      when(mockClient.send(any)).thenThrow(Exception('Network Error'));

      viewModel.updateCaption('Test Caption');
      viewModel.selectedImage = file;

      expect(
        () async => await viewModel.addPost(viewModel.caption, file),
        throwsA(isA<Exception>()),
      );
    });

    test('addPost should set isLoading correctly', () async {
      final file = File('test_image.jpg');
      await file.create();

      final mockResponse = http.StreamedResponse(
        Stream.value(utf8.encode('')),
        200,
      );

      when(mockClient.send(any)).thenAnswer((_) async => mockResponse);

      viewModel.updateCaption('Test Caption');
      viewModel.selectedImage = file;

      expect(viewModel.isLoading, false);
      final future = viewModel.addPost(viewModel.caption, file);
      expect(viewModel.isLoading, true);
      await future;
      expect(viewModel.isLoading, false);
    });
  });
}
