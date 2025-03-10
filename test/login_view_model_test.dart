import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapgram/api_service.dart';
import 'package:snapgram/viewModels/login_view_model.dart';

import 'login_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('LoginViewModel', () {
    late LoginViewModel viewModel;
    late MockClient mockClient;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockClient = MockClient();
      ApiService.setHttpClient(mockClient);
      viewModel = LoginViewModel();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      reset(mockClient);
    });

    test(
      'login should set isAuthenticated to true on successful login',
      () async {
        final mockResponse = {'username': 'testuser', 'token': 'mockToken'};

        when(
          mockClient.post(
            Uri.parse('${ApiService.baseUrl}/auth/login'),
            body: json.encode({'username': 'testuser', 'password': 'password'}),
            headers: {'Content-Type': 'application/json'},
          ),
        ).thenAnswer(
          (_) async => http.Response(json.encode(mockResponse), 200),
        );

        await viewModel.login('testuser', 'password');

        expect(viewModel.isAuthenticated, true);
        expect(viewModel.user?.username, 'testuser');
        expect(viewModel.user?.token, 'mockToken');
        expect(viewModel.isLoading, false);
        expect(viewModel.errorMessage, '');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('token'), 'mockToken');

        verify(
          mockClient.post(
            Uri.parse('${ApiService.baseUrl}/auth/login'),
            body: json.encode({'username': 'testuser', 'password': 'password'}),
            headers: {'Content-Type': 'application/json'},
          ),
        ).called(1);
      },
    );

    test('login should set errorMessage on invalid credentials', () async {
      when(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/login'),
          body: json.encode({
            'username': 'testuser',
            'password': 'wrongpassword',
          }),
          headers: {'Content-Type': 'application/json'},
        ),
      ).thenAnswer(
        (_) async => http.Response('Invalid username or password', 403),
      );

      await viewModel.login('testuser', 'wrongpassword');

      expect(viewModel.isAuthenticated, false);
      expect(viewModel.user, null);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, 'Invalid username or password');

      verify(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/login'),
          body: json.encode({
            'username': 'testuser',
            'password': 'wrongpassword',
          }),
          headers: {'Content-Type': 'application/json'},
        ),
      ).called(1);
    });

    test('login should handle exceptions', () async {
      when(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/login'),
          body: json.encode({'username': 'testuser', 'password': 'password'}),
          headers: {'Content-Type': 'application/json'},
        ),
      ).thenThrow(Exception('Network Error'));

      expect(
        () async => await viewModel.login('testuser', 'password'),
        throwsA(isA<Exception>()),
      );
    });

    test('login should set isLoading correctly', () async {
      final mockResponse = {'username': 'testuser', 'token': 'mockToken'};

      when(
        mockClient.post(
          Uri.parse('${ApiService.baseUrl}/auth/login'),
          body: json.encode({'username': 'testuser', 'password': 'password'}),
          headers: {'Content-Type': 'application/json'},
        ),
      ).thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      expect(viewModel.isLoading, false);
      final future = viewModel.login('testuser', 'password');
      expect(viewModel.isLoading, true);
      await future;
      expect(viewModel.isLoading, false);
    });

    test('logout should reset state', () {
      viewModel.logout();

      expect(viewModel.isAuthenticated, false);
      expect(viewModel.user, null);
      expect(viewModel.isLoading, false);
    });
  });
}
