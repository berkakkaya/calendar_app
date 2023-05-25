import 'dart:io';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/authentication.dart';
import 'package:calendar_app/models/response_status.dart';
import 'package:calendar_app/models/user.dart';
import 'package:calendar_app/models/user_list.dart';
import 'package:dio/dio.dart';

class ApiManager {
  static String? _apiUrl;

  static String? _accessToken;
  static String? _refreshToken;

  static bool get isReady => _apiUrl != null;
  static bool get isAuthenticated =>
      _refreshToken != null && _accessToken != null;

  // Setup Dio
  static final Dio _dio = Dio(BaseOptions(
    sendTimeout: const Duration(seconds: 20),
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    },
    responseType: ResponseType.json,
    validateStatus: (code) => code != null,
  ));

  /// Initializes the API manager with given base URL
  ///
  /// This function checks if the given base URL is working and finalizes the
  /// initialization process. Other functions of the API manager cannot be used
  /// without a proper initialization process were made.
  static Future<void> initialize({required String baseUrl}) async {
    _apiUrl = Uri.tryParse(baseUrl).toString();

    // Try to send a test request
    try {
      final response = await _dio.get(baseUrl);

      if (response.statusCode == 200 &&
          response.data["message"] == apiTestString) {
        return;
      }
    } catch (e) {
      // We don't need to do anything here, this condition is already
      // handled in the code below.
    }

    // Checks have failed, return to null
    _apiUrl = null;
  }

  static void setRefreshToken({
    String? refreshToken,
  }) {
    _refreshToken = refreshToken;
  }

  static Future<ResponseStatus> getNewToken() async {
    if (!isReady) return ResponseStatus.none;
    if (_refreshToken == null) return ResponseStatus.authorizationError;

    final response = await _dio.post<Map<String, dynamic>>(
      "${_apiUrl!}/token",
      options: Options(headers: {
        HttpHeaders.authorizationHeader: getAuthorizationString(
          isAccessToken: false,
        ),
      }),
    );

    if ([400, 401].contains(response.statusCode)) {
      _refreshToken = null;
      return ResponseStatus.authorizationError;
    }

    _accessToken = response.data!["access_token"];
    return ResponseStatus.success;
  }

  static String? getAuthorizationString({bool isAccessToken = true}) {
    if (isAccessToken) {
      return _accessToken == null ? "Bearer $_accessToken" : null;
    }

    return _refreshToken == null ? "Bearer $_refreshToken" : null;
  }

  /// Log into an account and returns tokens
  ///
  /// This function logs in to an account with given email and password.
  /// If successful, `Authentication` object will include an access token
  /// and a refresh token.
  /// If the API manager isn't ready, the response status will be `none`.
  /// If the email or the password is wrong, response status will be
  /// `wrongEmailOrPassword`.
  static Future<Authentication> login({
    required String email,
    required String password,
  }) async {
    if (!isReady) {
      return Authentication(responseStatus: ResponseStatus.none);
    }

    final response = await _dio.post(
      "${_apiUrl!}/login",
      data: {"email": email, "password": password},
    );

    if (response.statusCode! == 403) {
      return Authentication(
        responseStatus: ResponseStatus.wrongEmailOrPassword,
      );
    }

    return Authentication.fromJson(ResponseStatus.success, response.data);
  }

  /// Create a new account and log into it
  ///
  /// This function creates a new account based on the given info and tries to
  /// create a new account. If successfull, `Authentication` object will include
  /// an access token and a refresh token. If an account with similar username
  /// and/or similar email exists, status will be set to `duplicateExists`.
  static Future<Authentication> register({
    required String name,
    required String surname,
    required String email,
    required String username,
    required String password,
    required int tcIdentityNumber,
    required String phone,
    required String address,
  }) async {
    if (!isReady) {
      return Authentication(responseStatus: ResponseStatus.none);
    }

    final response = await _dio.post("${_apiUrl!}/register", data: {
      "name": name,
      "surname": surname,
      "email": email,
      "password": password,
      "tc_identity_number": tcIdentityNumber,
      "phone": phone,
      "address": address,
    });

    if (response.statusCode! == 409) {
      return Authentication(responseStatus: ResponseStatus.duplicateExists);
    }

    return Authentication.fromJson(ResponseStatus.success, response.data);
  }

  static Future<UserList> getUsersList() async {
    if (!isReady) {
      return UserList(responseStatus: ResponseStatus.none);
    }

    if (!isAuthenticated) {
      return UserList(responseStatus: ResponseStatus.authorizationError);
    }

    final response = await _dio.get(
      "${_apiUrl!}/users",
      options: Options(headers: {
        HttpHeaders.authorizationHeader: getAuthorizationString(),
      }),
    );

    if ([401, 403].contains(response.statusCode)) {
      return UserList(responseStatus: ResponseStatus.authorizationError);
    }

    List<UserNonResponse> list = [];

    for (Map<String, dynamic> user in response.data) {
      list.add(UserNonResponse.fromJson(user));
    }

    return UserList(responseStatus: ResponseStatus.success, userList: list);
  }
}
