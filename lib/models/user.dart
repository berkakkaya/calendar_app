import 'package:calendar_app/models/response_status.dart';

class User {
  final ResponseStatus responseStatus;

  String? name;
  String? surname;
  String? username;

  User({required this.responseStatus, this.name, this.surname, this.username});

  User.fromJson(this.responseStatus, Map<String, dynamic> json) {
    name = json['name'];
    surname = json['surname'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['name'] = name;
    data['surname'] = surname;
    data['username'] = username;

    return data;
  }
}
