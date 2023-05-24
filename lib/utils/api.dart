import 'dart:io';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/authentication.dart';
import 'package:calendar_app/models/response_status.dart';
import 'package:dio/dio.dart';

class ApiManager {
  static String? _apiUrl;
  static bool isReady = false;

  static final Dio _dio = Dio(BaseOptions(
    sendTimeout: const Duration(seconds: 20),
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    },
    responseType: ResponseType.json,
  ));

  static Future<void> initialize({required String baseUrl}) async {
    _apiUrl = Uri.tryParse(baseUrl).toString();

    // Try to send a test request
    try {
      final response = await _dio.get(baseUrl);

      if (response.statusCode == 200 &&
          response.data["message"] == apiTestString) {
        isReady = true;
        return;
      }

      isReady = false;
    } catch (e) {
      isReady = false;
    }
  }

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
}
