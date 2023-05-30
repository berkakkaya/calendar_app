import 'package:animations/animations.dart';
import 'package:calendar_app/consts/colors.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/base_response.dart';
import 'package:calendar_app/models/response_status.dart';
import 'package:calendar_app/screens/login_register/welcome_screen.dart';
import 'package:calendar_app/utils/api.dart';
import 'package:calendar_app/widgets/popups.dart';
import 'package:flutter/material.dart';

Future<bool> checkAuthenticationStatus({
  required BuildContext context,
  required Future<BaseResponse> Function() apiCall,
}) async {
  BaseResponse response = await apiCall();

  if (response.responseStatus != ResponseStatus.authorizationError) {
    return true;
  }

  final accessTokenResponse = await ApiManager.getNewAccessToken();

  if (accessTokenResponse == ResponseStatus.authorizationError) {
    if (context.mounted) {
      await showWarningPopup(
        context: context,
        title: "Oturum kapatıldı",
        content: [
          const Text(loggedOutWarning),
        ],
      );
    }

    if (context.mounted) {
      await _goToWelcomeScreen(context);
    }

    return false;
  }

  response = await apiCall();
  return response.responseStatus == ResponseStatus.authorizationError
      ? false
      : true;
}

Future<void> _goToWelcomeScreen(BuildContext context) async {
  await Navigator.of(context).pushAndRemoveUntil(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return const WelcomeScreen();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          transitionType: SharedAxisTransitionType.horizontal,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: color1,
          child: child,
        );
      },
    ),
    (route) => false,
  );
}
