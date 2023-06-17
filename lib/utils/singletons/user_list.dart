import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/user.dart';
import 'package:calendar_app/models/user_list.dart';
import 'package:calendar_app/utils/api.dart';

class SUserList {
  static List<UserNonResponse>? _userList;

  static Future<List<UserNonResponse>> get userList async {
    if (_userList != null) return _userList!;

    UserList responseUserList = await ApiManager.getUsersList();

    if (responseUserList.responseStatus == ResponseStatus.authorizationError) {
      if (await ApiManager.getNewAccessToken() == null) {
        return [];
      }

      responseUserList = await ApiManager.getUsersList();
    }

    if (responseUserList.responseStatus != ResponseStatus.success) return [];
    _userList = responseUserList.userList;

    // Remove our user's ID from the list
    final User responseUser = await ApiManager.getUser();

    if (responseUser.responseStatus == ResponseStatus.success) {
      _userList?.removeWhere(
        (element) => element.userId == responseUser.userId!,
      );
    }

    return _userList!;
  }
}
