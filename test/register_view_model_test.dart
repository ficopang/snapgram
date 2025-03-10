import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/models/user_register_model.dart';
import 'package:snapgram/viewModels/register_view_model.dart';

import 'register_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('RegisterViewModel', () {
    late RegisterViewModel viewModel;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      ApiService.setHttpClient(mockClient);
      viewModel = RegisterViewModel();
    });

    tearDown(() {
      reset(mockClient);
    });

    test(
      'register should set isSuccess to true and user on successful registration',
      () async {
        final mockResponse = {
          'username': 'testuser',
          'password': 'password123',
        };

        when(
          mockClient.post(
            Uri.parse('${ApiService.baseUrl}/auth/register'),
            body: json.encode({
              'username': 'testuser',
              'password': 'password123',
            }),
            headers: {'Content-Type': 'application/json'},
          ),
        ).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        await viewModel.register('testuser', 'password123');

        expect(viewModel.isSuccess, true);
        expect(viewModel.user, isA<UserRegisterModel>());
        expect(viewModel.user?.username, 'testuser');
        expect(viewModel.user?.password, 'password123');
        expect(viewModel.isLoading, false);

        verify(
          mockClient.post(
            Uri.parse('${ApiService.baseUrl}/auth/register'),
            body: json.encode({
              'username': 'testuser',
              'password': 'password123',
            }),
            headers: {'Content-Type': 'application/json'},
          ),
        ).called(1);
      },
    );

    test('register should set isLoading correctly', () async {
      final mockResponse = {'username': 'testuser', 'password': 'password123'};

      when(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/register'),
          body: json.encode({
            'username': 'testuser',
            'password': 'password123',
          }),
          headers: {'Content-Type': 'application/json'},
        ),
      ).thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      expect(viewModel.isLoading, false);

      final future = viewModel.register('testuser', 'password123');

      expect(viewModel.isLoading, true);

      await future;

      expect(viewModel.isLoading, false);
    });

    test('register should throw exception if http call fails', () async {
      when(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/register'),
          body: json.encode({
            'username': 'testuser',
            'password': 'password123',
          }),
          headers: {'Content-Type': 'application/json'},
        ),
      ).thenThrow(Exception('Network Error'));

      expect(
        () async => await viewModel.register('testuser', 'password123'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
