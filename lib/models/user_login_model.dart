class UserLoginModel {
  final String username;
  final String token;

  UserLoginModel({required this.username, required this.token});

  get getToken => token;

  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    return UserLoginModel(username: json['username'], token: json['token']);
  }
}
