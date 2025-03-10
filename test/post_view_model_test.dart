import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/viewModels/post_view_model.dart';

import 'post_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('PostViewModel', () {
    late PostViewModel viewModel;
    late MockClient mockClient;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockClient = MockClient();
      ApiService.setHttpClient(mockClient);
      viewModel = PostViewModel();
      SharedPreferences.setMockInitialValues({});
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString('token', 'mockToken');
    });

    tearDown(() {
      reset(mockClient);
    });

    test('fetchPosts should set posts on successful fetch', () async {
      final mockResponse = [
        {
          'id': 1,
          'username': 'testuser',
          'imageUrl': 'url1',
          'caption': 'Test Post 1',
          'likeCount': 10,
          'createdAt': '2023-10-27T10:00:00Z',
          'liked': true,
        },
        {
          'id': 2,
          'username': 'anotheruser',
          'imageUrl': 'url2',
          'caption': 'Test Post 2',
          'likeCount': 5,
          'createdAt': '2023-10-28T11:00:00Z',
          'liked': false,
        },
      ];

      when(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/posts'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      await viewModel.fetchPosts();

      expect(viewModel.posts.length, 2);
      expect(viewModel.posts[0].id, 1);
      expect(viewModel.posts[0].username, 'testuser');
      expect(viewModel.posts[0].imageUrl, 'url1');
      expect(viewModel.posts[0].caption, 'Test Post 1');
      expect(viewModel.posts[0].likeCount, 10);
      expect(viewModel.posts[0].createdAt, '2023-10-27T10:00:00Z');
      expect(viewModel.posts[0].liked, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, '');

      verify(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/posts'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).called(1);
    });

    test('fetchPosts should set errorMessage on unauthorized fetch', () async {
      when(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/posts'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 403));

      await viewModel.fetchPosts();

      expect(viewModel.posts.length, 0);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, 'Unauthorized');

      verify(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/posts'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).called(1);
    });

    test('fetchPosts should handle exceptions', () async {
      when(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/posts'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).thenThrow(Exception('Network Error'));

      expect(
        () async => await viewModel.fetchPosts(),
        throwsA(isA<Exception>()),
      );
    });

    test('fetchPosts should set isLoading correctly', () async {
      final mockResponse = [
        {
          'id': 1,
          'username': 'testuser',
          'imageUrl': 'url1',
          'caption': 'Test Post 1',
          'likeCount': 10,
          'createdAt': '2023-10-27T10:00:00Z',
          'liked': true,
        },
      ];

      when(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/posts'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      expect(viewModel.isLoading, false);
      final future = viewModel.fetchPosts();
      expect(viewModel.isLoading, true);
      await future;
      expect(viewModel.isLoading, false);
    });
  });
}
