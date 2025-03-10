import 'package:snapgram/models/reply_model.dart';

class CommentModel {
  final int id;
  final String postId;
  final String username;
  final String text;
  final DateTime createdAt;
  final List<Reply> replies;

  CommentModel({
    required this.id,
    required this.postId,
    required this.username,
    required this.text,
    required this.replies,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['postId'],
      username: json['username'],
      text: json['text'],
      replies:
          (json['replies'] as List<dynamic>)
              .map((reply) => Reply.fromJson(reply))
              .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
