class LoginData {
  final String email;
  final String password;

  LoginData({
    required this.email,
    required this.password,
  });

  Map<String, String> toJson() {
    Map<String, String> data = {};

    data["email"] = email;
    data["password"] = password;

    return data;
  }
}
