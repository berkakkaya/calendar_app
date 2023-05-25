import 'package:calendar_app/models/response_status.dart';
import 'package:calendar_app/models/user.dart';

class UserList {
  final ResponseStatus responseStatus;
  List<UserNonResponse>? userList;

  UserList({required this.responseStatus, this.userList});

  List<String> toJsonIdList() {
    final List<String> data = [];

    for (UserNonResponse user in userList!) {
      data.add(user.userId);
    }

    return data;
  }
}
