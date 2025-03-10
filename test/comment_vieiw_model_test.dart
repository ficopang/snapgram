import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/viewModels/comment_view_model.dart';

import 'comment_vieiw_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('CommentViewModel', () {
    late CommentViewModel viewModel;
    late MockClient mockClient;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockClient = MockClient();
      ApiService.setHttpClient(mockClient);
      viewModel = CommentViewModel();
      SharedPreferences.setMockInitialValues({});
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString('token', 'mockToken');
    });

    tearDown(() {
      reset(mockClient);
    });

    test('fetchComments should set comments on successful fetch', () async {
      final mockResponse = [
        {
          'id': 1,
          'postId': '1',
          'username': 'testuser',
          'text': 'Comment 1',
          'createdAt': '2023-10-27T10:00:00Z',
        },
        {
          'id': 2,
          'postId': '1',
          'username': 'anotheruser',
          'text': 'Comment 2',
          'createdAt': '2023-10-28T11:00:00Z',
        },
      ];

      when(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      await viewModel.fetchComments('1');

      expect(viewModel.comments.length, 2);
      expect(viewModel.comments[0].id, 1);
      expect(viewModel.comments[0].text, 'Comment 1');
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, '');

      verify(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).called(1);
    });

    test(
      'fetchComments should set errorMessage on unauthorized fetch',
      () async {
        when(
          mockClient.get(
            Uri.parse('${ApiService.baseUrl}/comments/1'),
            headers: {'Authorization': 'Bearer mockToken'},
          ),
        ).thenAnswer((_) async => http.Response('Unauthorized', 403));

        await viewModel.fetchComments('1');

        expect(viewModel.comments.length, 0);
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, 'Unauthorized');

        verify(
          mockClient.get(
            Uri.parse('${ApiService.baseUrl}/comments/1'),
            headers: {'Authorization': 'Bearer mockToken'},
          ),
        ).called(1);
      },
    );

    test('fetchComments should handle exceptions', () async {
      when(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).thenThrow(Exception('Network Error'));

      expect(
        () async => await viewModel.fetchComments('1'),
        throwsA(isA<Exception>()),
      );
    });

    test('fetchComments should set isLoading correctly', () async {
      final mockResponse = [
        {
          'id': 1,
          'postId': '1',
          'username': 'testuser',
          'text': 'Comment 1',
          'createdAt': '2023-10-27T10:00:00Z',
        },
      ];

      when(
        mockClient.get(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
        ),
      ).thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      expect(viewModel.isLoading, false);
      final future = viewModel.fetchComments('1');
      expect(viewModel.isLoading, true);
      await future;
      expect(viewModel.isLoading, false);
    });

    test('addComment should handle successful add', () async {
      when(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
          body: {"text": "Test Comment"},
        ),
      ).thenAnswer((_) async => http.Response('OK', 200));

      await viewModel.addComment(1, 'Test Comment');

      expect(viewModel.errorMessage, '');

      verify(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
          body: {"text": "Test Comment"},
        ),
      ).called(1);
    });

    test('addComment should set errorMessage on unauthorized add', () async {
      when(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
          body: {"text": "Test Comment"},
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 403));

      await viewModel.addComment(1, 'Test Comment');

      expect(viewModel.errorMessage, 'Unauthorized');

      verify(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
          body: {"text": "Test Comment"},
        ),
      ).called(1);
    });

    test('addComment should set errorMessage on failed add', () async {
      when(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
          body: {"text": "Test Comment"},
        ),
      ).thenAnswer((_) async => http.Response('Failed to add Comment', 500));

      await viewModel.addComment(1, 'Test Comment');

      expect(viewModel.errorMessage, 'Failed to add Comment');

      verify(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
          body: {"text": "Test Comment"},
        ),
      ).called(1);
    });

    test('addComment should handle exceptions', () async {
      when(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/comments/1'),
          headers: {'Authorization': 'Bearer mockToken'},
          body: {"text": "Test Comment"},
        ),
      ).thenThrow(Exception('Network Error'));

      expect(
        () async => await viewModel.addComment(1, 'Test Comment'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
