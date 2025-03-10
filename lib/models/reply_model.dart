class Reply {
  final int id;
  final String content;
  final String username;

  Reply({required this.id, required this.content, required this.username});

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'],
      content: json['content'],
      username: json['username'],
    );
  }
}
