import 'package:snapgram/models/post_model.dart';

class LikeModel {
  final String username;
  final PostModel post;

  LikeModel({required this.username, required this.post});

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      username: json['username'],
      post: PostModel.fromJson(json['post']),
    );
  }
}
