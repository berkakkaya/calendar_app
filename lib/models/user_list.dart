import 'package:calendar_app/models/base_response.dart';
import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/user.dart';

class UserList implements BaseResponse {
  @override
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
