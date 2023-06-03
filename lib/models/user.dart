import 'package:calendar_app/models/base_response.dart';
import 'package:calendar_app/models/enums.dart';

class User implements BaseResponse {
  @override
  final ResponseStatus responseStatus;

  String? userId;
  String? name;
  String? surname;
  String? username;

  User({required this.responseStatus, this.name, this.surname, this.username});

  User.fromJson(this.responseStatus, Map<String, dynamic> json) {
    name = json['_id'];
    name = json['name'];
    surname = json['surname'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['user_id'] = userId;
    data['name'] = name;
    data['surname'] = surname;
    data['username'] = username;

    return data;
  }
}

class UserNonResponse {
  late String userId;
  late String name;
  late String surname;
  late String username;

  UserNonResponse({
    required this.userId,
    required this.name,
    required this.surname,
    required this.username,
  });

  UserNonResponse.fromJson(Map<String, dynamic> data) {
    userId = data["_id"];
    name = data["name"];
    surname = data["surname"];
    username = data["username"];
  }
}
