import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/utils/api.dart';
import 'package:calendar_app/utils/checks.dart';
import 'package:calendar_app/widgets/popups.dart';
import 'package:flutter/material.dart';

/// Creates a event with given parameters
///
/// Unlike the API Manager's function, this function does all the checks
/// and manages the entire flow. You can use this in pages directly.
///
/// This function returns `false` if operation has failed, `true` if otherwise.
Future<bool> createEvent({
  required BuildContext context,
  required EventLongForm event,
}) async {
  // Check if any null value exists in required fields
  if (event.isThereAnyReqiredEmpty()) {
    showWarningPopup(
      context: context,
      title: "Boş giriş",
      content: [const Text(modifyEventEmptyWarning)],
    );

    return false;
  }

  // Check if date data is valid
  DateTime now = DateTime.now();
  List<bool> requiredDateConditions = [];

  requiredDateConditions.add(event.startsAt!.isAfter(now));
  requiredDateConditions.add(event.endsAt!.isAfter(event.startsAt!));
  requiredDateConditions.add(
    !event.startsAt!.isAtSameMomentAs(event.endsAt!),
  );

  if (requiredDateConditions.contains(false)) {
    showWarningPopup(
      context: context,
      title: "Geçersiz tarih girişi",
      content: [const Text(invalidDateWarning)],
    );

    return false;
  }

  // Try to create the event
  late EventLongForm response;

  final isLoggedIn = await checkAuthenticationStatus(
    context: context,
    apiCall: () async {
      response = await ApiManager.createEvent(event: event);
      return response;
    },
  );

  if (!isLoggedIn) {
    return false;
  }

  if (response.responseStatus == ResponseStatus.serverError) {
    if (context.mounted) {
      await showWarningPopup(
        context: context,
        title: "Sunucu hatası",
        content: [const Text(serverError)],
      );
    }

    return false;
  }

  if (response.responseStatus == ResponseStatus.invalidRequest) {
    if (context.mounted) {
      await showWarningPopup(
        context: context,
        title: "Geçersiz giriş",
        content: [const Text(modifyEventEmptyWarning)],
      );
    }

    return false;
  }

  // Operation is successful, return true
  return true;
}
