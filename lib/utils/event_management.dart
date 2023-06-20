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
Future<String?> createEvent({
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

    return null;
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

    return null;
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
    return null;
  }

  if (response.responseStatus == ResponseStatus.serverError) {
    if (context.mounted) {
      await showWarningPopup(
        context: context,
        title: "Sunucu hatası",
        content: [const Text(serverError)],
      );
    }

    return null;
  }

  if (response.responseStatus == ResponseStatus.invalidRequest) {
    if (context.mounted) {
      await showWarningPopup(
        context: context,
        title: "Geçersiz giriş",
        content: [const Text(modifyEventEmptyWarning)],
      );
    }

    return null;
  }

  // Operation is successful, return true
  return response.eventId!;
}

/// Modifies the event with given parameters
///
/// Unlike the API Manager's function, this function does all the checks
/// and manages the entire flow. You can use this in pages directly.
///
/// This function returns `false` if operation has failed, `true` if otherwise.
Future<bool> modifyEvent({
  required BuildContext context,
  required EventLongForm event,
}) async {
  if (!context.mounted) return false;

  final checksPassed = await _makeChecks(context, event);
  if (!checksPassed) return false;

  // Try to modify the event
  late ResponseStatus response;
  bool isLoggedIn = false;

  if (context.mounted) {
    isLoggedIn = await checkAuthenticationStatus(
      context: context,
      apiCall: () async {
        response = await ApiManager.modifyEvent(event: event);

        // Again, another hacky way. Gotta fix these.
        // TODO: Find a better way for these if you can
        return EventLongForm(responseStatus: response);
      },
    );
  }

  if (!isLoggedIn) {
    return false;
  }

  if (response == ResponseStatus.serverError) {
    if (context.mounted) {
      await showWarningPopup(
        context: context,
        title: "Sunucu hatası",
        content: [const Text(serverError)],
      );
    }

    return false;
  }

  if (response == ResponseStatus.invalidRequest) {
    if (context.mounted) {
      await showWarningPopup(
        context: context,
        title: "Geçersiz giriş",
        content: [const Text(modifyEventEmptyWarning)],
      );
    }

    return false;
  }

  if (response == ResponseStatus.notFound) {
    if (context.mounted) {
      await showWarningPopup(
        context: context,
        title: "Etkinlik bulunamadı",
        content: [
          const Text("Düzenlemeye çalıştığınız etkinlik artık mevcut değil."),
        ],
      );
    }

    return false;
  }

  if (response == ResponseStatus.accessDenied) {
    if (context.mounted) {
      await showWarningPopup(
        context: context,
        title: "İzin yok",
        content: [
          const Text("Bu etkinliği düzenlemeye izniniz yok."),
        ],
      );
    }

    return false;
  }

  // Operation is successful, return true
  return true;
}

Future<bool> _makeChecks(BuildContext context, EventLongForm event) async {
  // Check if any null value exists in required fields
  if (event.isThereAnyReqiredEmpty()) {
    await showWarningPopup(
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
    await showWarningPopup(
      context: context,
      title: "Geçersiz tarih girişi",
      content: [const Text(invalidDateWarning)],
    );

    return false;
  }

  return true;
}
