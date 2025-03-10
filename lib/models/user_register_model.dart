class UserRegisterModel {
  String username;
  String password;

  UserRegisterModel({required this.username, required this.password});

  factory UserRegisterModel.fromJson(Map<String, dynamic> json) {
    return UserRegisterModel(
      username: json['username'],
      password: json['password'],
    );
  }
}
