import 'package:calendar_app/models/user.dart';

class UserCheckboxData {
  final UserNonResponse user;
  bool checked;

  UserCheckboxData({required this.user, this.checked = false});
}
