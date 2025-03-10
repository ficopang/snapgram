import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapgram/viewModels/login_view_model.dart';
import 'package:toastification/toastification.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<LoginViewModel>(context);

    if (authViewModel.isAuthenticated) {
      // Navigate to Home page
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/home'));

      // Show success message
      Future.microtask(
        () => toastification.show(
          title: Text('Login success'),
          autoCloseDuration: const Duration(seconds: 5),
        ),
      );
    } else if (authViewModel.errorMessage.isNotEmpty) {
      // Show error message
      Future.microtask(
        () => toastification.show(
          title: Text(authViewModel.errorMessage),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 5),
        ),
      );
    }

    return Scaffold(
      body:
          authViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'SnapGram',
                      style: GoogleFonts.lato(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'username',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _username = value!;
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  // Lakukan logika login di sini
                                  print(
                                    'Username: $_username, Password: $_password',
                                  );

                                  authViewModel.login(_username, _password);
                                }
                              },
                              child: Text('Log in'),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              );
                            },
                            child: Text('Register'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
