import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapgram/viewModels/comment_view_model.dart';
import 'package:snapgram/viewModels/like_view_model.dart';
import 'package:snapgram/viewModels/login_view_model.dart';
import 'package:snapgram/viewModels/post_view_model.dart';
import 'package:snapgram/viewModels/profile_view_model.dart';
import 'package:snapgram/viewModels/register_view_model.dart';
import 'package:snapgram/views/add_post_view.dart';
import 'package:snapgram/views/explore_view.dart';
import 'package:snapgram/views/like_view.dart';
import 'package:snapgram/views/login_view.dart';
import 'package:snapgram/views/home_view.dart';
import 'package:snapgram/views/profile_view.dart';
import 'package:snapgram/views/register_view.dart';
import 'package:snapgram/views/story_view.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginViewModel()),
        ChangeNotifierProvider(create: (context) => RegisterViewModel()),
        ChangeNotifierProvider(create: (context) => PostViewModel()),
        ChangeNotifierProvider(create: (context) => CommentViewModel()),
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
        ChangeNotifierProvider(create: (context) => LikeViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'SnapGram',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.black,
            secondary: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginView(),
          '/register': (context) => RegisterView(),
          '/home': (context) => Home(),
          '/create_post': (context) => AddPostView(),
          '/explore': (context) => ExploreView(),
          '/profile': (context) => ProfileView(),
          '/like': (context) => LikeView(),
          '/story':
              (context) => StoryView(
                imagePath:
                    "http://10.0.2.2:8080/uploads/c766fef5-6350-4368-bbcc-b624a9f57924_IMG_20250308_164904.jpg",
              ),
        },
      ),
    );
  }
}
