import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/user.dart';
import 'package:calendar_app/models/user_list.dart';
import 'package:calendar_app/utils/api.dart';

class SUser {
  static List<UserNonResponse>? _userList;
  static FullUser? _user;

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

    return _userList!;
  }

  static Future<FullUser> get user async {
    if (_user != null) return _user!;

    FullUser response = await ApiManager.getProfile();

    if (response.responseStatus == ResponseStatus.authorizationError) {
      if (await ApiManager.getNewAccessToken() == null) {
        return FullUser(responseStatus: ResponseStatus.none);
      }

      response = await ApiManager.getProfile();
    }

    if (response.responseStatus != ResponseStatus.success) {
      return FullUser(responseStatus: ResponseStatus.none);
    }

    _user = response;
    return _user!;
  }

  static void resetAll() {
    _userList = null;
    _user = null;
  }
}
