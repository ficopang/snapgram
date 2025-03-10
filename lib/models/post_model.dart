class PostModel {
  final int id;
  final String username;
  final String createdAt;
  final String imageUrl;
  final String caption;
  final int likeCount;
  final bool liked;

  PostModel({
    required this.id,
    required this.username,
    required this.imageUrl,
    required this.caption,
    required this.likeCount,
    required this.createdAt,
    required this.liked,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      username: json['username'],
      imageUrl: json['imageUrl'],
      caption: json['caption'],
      likeCount: json['likeCount'],
      createdAt: json['createdAt'],
      liked: json['liked'],
    );
  }
}
