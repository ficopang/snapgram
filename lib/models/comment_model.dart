class CommentModel {
  final int id;
  final String postId;
  final String username;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.username,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['postId'],
      username: json['username'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
