import 'package:calendar_app/models/response_status.dart';

class Authentication {
  final ResponseStatus responseStatus;
  String? accessToken;
  String? refreshToken;

  Authentication({
    required this.responseStatus,
    this.accessToken,
    this.refreshToken,
  });

  Authentication.fromJson(this.responseStatus, Map<String, dynamic> json) {
    accessToken = json["access_token"];
    refreshToken = json["refresh_token"];
  }
}
