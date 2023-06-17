import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/models/user.dart';
import 'package:calendar_app/utils/api.dart';
import 'package:calendar_app/utils/checks.dart';
import 'package:calendar_app/utils/formatter.dart';
import 'package:calendar_app/utils/singletons/user_list.dart';
import 'package:calendar_app/widgets/info_placeholder.dart';
import 'package:calendar_app/widgets/popups.dart';
import 'package:flutter/material.dart';

class ViewEventScreen extends StatefulWidget {
  const ViewEventScreen({super.key, required this.event});
  final EventShortForm event;

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  EventLongForm? fullEvent;
  User? createdBy;
  late List<UserNonResponse> users;

  @override
  void initState() {
    super.initState();

    fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Etkinlik"),
      ),
      body: fullEvent != null && createdBy != null
          ? _LoadedEventView(
              event: fullEvent!,
              createdBy: createdBy!,
              userList: users,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> fetchAll() async {
    final EventLongForm? fetchedEvent = await _fetchFullEvent();

    if (fetchedEvent == null) return;

    fullEvent = fetchedEvent;
    final User? fetchedUser = await _fetchUser();

    if (fetchedUser == null) return;

    createdBy = fetchedUser;

    users = await SUserList.userList;

    if (createdBy != null && context.mounted) {
      setState(() {});
    }
  }

  Future<EventLongForm?> _fetchFullEvent() async {
    late EventLongForm response;

    final isAuthorized = await checkAuthenticationStatus(
      context: context,
      apiCall: () async {
        response = await ApiManager.getEvent(eventId: widget.event.eventId!);
        return response;
      },
    );

    if (!isAuthorized) {
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
          title: "Geçersiz istek hatası",
          content: [
            const Text("Bunun oluşmaması gerek. Lütfen yeniden deneyiniz."),
          ],
        );
      }

      return null;
    }

    return response;
  }

  Future<User?> _fetchUser() async {
    if (fullEvent == null) return null;

    late User response;

    final isAuthorized = await checkAuthenticationStatus(
      context: context,
      apiCall: () async {
        response = await ApiManager.getUser(userId: fullEvent!.createdBy!);
        return response;
      },
    );

    if (!isAuthorized) {
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
          title: "Geçersiz istek hatası",
          content: [
            const Text("Bunun oluşmaması gerek. Lütfen yeniden deneyiniz."),
          ],
        );
      }

      return null;
    }

    return response;
  }
}

class _LoadedEventView extends StatelessWidget {
  final EventLongForm event;
  final User createdBy;
  final List<UserNonResponse> userList;

  const _LoadedEventView({
    required this.event,
    required this.createdBy,
    required this.userList,
  });

  @override
  Widget build(BuildContext context) {
    final timeStart = TimeOfDay.fromDateTime(event.startsAt!);
    final timeEnd = TimeOfDay.fromDateTime(event.endsAt!);

    final strCreatedBy =
        "${createdBy.name!} ${createdBy.surname!} @${createdBy.username}";

    final strTimeFormatted =
        "${timeStart.format(context)} • ${timeEnd.format(context)}";

    String strListParticipants = _getParticipantString();

    if (strListParticipants == "") {
      strListParticipants = "Katılımcı yok.";
    }

    String strRemindAt = "Bildirim yok.";

    if (event.remindAt!.isNotEmpty) {
      strRemindAt = "${event.remindAt!.first} dakika önce";
    }

    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        InfoPlaceholder(
          icon: const Icon(Icons.calendar_today_rounded),
          title: "Etkinlik adı",
          content: Text(event.name!),
        ),
        const SizedBox(height: 32),
        InfoPlaceholder(
          icon: const Icon(Icons.category_outlined),
          title: "Etkinlik türü",
          content: Text(event.type!),
        ),
        const SizedBox(height: 32),
        InfoPlaceholder(
          icon: const Icon(Icons.auto_awesome_outlined),
          title: "Toplantıyı oluşturan",
          content: Text(strCreatedBy),
        ),
        const SizedBox(height: 32),
        InfoPlaceholder(
          icon: const Icon(Icons.groups_outlined),
          title: "Katılımcılar",
          content: Text(strListParticipants),
        ),
        const SizedBox(height: 32),
        InfoPlaceholder(
          icon: const Icon(Icons.today_rounded),
          title: "Etkinlik Tarihi",
          content: Text(getDateFormatter(dateFormat).format(event.startsAt!)),
        ),
        const SizedBox(height: 32),
        InfoPlaceholder(
          icon: const Icon(Icons.schedule_rounded),
          title: "Etkinlik Saati",
          content: Text(strTimeFormatted),
        ),
        const SizedBox(height: 32),
        InfoPlaceholder(
          icon: const Icon(Icons.alarm_rounded),
          title: "Bildirimler",
          content: Text(strRemindAt),
        ),
      ],
    );
  }

  String _getParticipantString() {
    String strParticipants = "";

    for (final participantId in event.participants!) {
      final index = userList.indexWhere((user) => user.userId == participantId);

      if (index != -1) {
        final UserNonResponse participant = userList[index];

        strParticipants +=
            "${participant.name} ${participant.surname} (@${participant.username})\n";
      }
    }

    strParticipants = strParticipants.trim();

    return strParticipants;
  }
}
