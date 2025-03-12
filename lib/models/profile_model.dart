import 'package:snapgram/models/post_model.dart';

class ProfileModel {
  final String username;
  final List<PostModel> posts;

  ProfileModel({required this.username, required this.posts});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      username: json['username'],
      posts:
          (json['posts'] as List<dynamic>)
              .map((posts) => PostModel.fromJson(posts))
              .toList(),
    );
  }
}
