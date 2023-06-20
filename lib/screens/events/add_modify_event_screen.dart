import 'package:animations/animations.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/models/user.dart';
import 'package:calendar_app/models/user_checkbox_data.dart';
import 'package:calendar_app/screens/events/add_participants_screen.dart';
import 'package:calendar_app/utils/datetime_picking.dart';
import 'package:calendar_app/utils/event_fetching_broadcaster.dart';
import 'package:calendar_app/utils/event_management.dart';
import 'package:calendar_app/utils/services/notification_service.dart';
import 'package:calendar_app/utils/singletons/s_user.dart';
import 'package:calendar_app/widgets/date_picker_card.dart';
import 'package:calendar_app/widgets/info_placeholder.dart';
import 'package:calendar_app/widgets/participants_card.dart';
import 'package:calendar_app/widgets/popups.dart';
import 'package:calendar_app/widgets/time_picker_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddModifyEventScreen extends StatefulWidget {
  final FormType formType;
  final EventLongForm? event;

  const AddModifyEventScreen({
    super.key,
    required this.formType,
    this.event,
  });

  @override
  State<AddModifyEventScreen> createState() => _AddModifyEventScreenState();
}

class _AddModifyEventScreenState extends State<AddModifyEventScreen> {
  late EventLongForm event;
  List<UserCheckboxData> userCheckData = [];

  bool loading = true;
  bool isSaving = false;

  DateTime? date;
  TimeOfDay? timeStart;
  TimeOfDay? timeEnd;

  final controllerEventName = TextEditingController();
  final controllerEventType = TextEditingController();
  final controllerEventNotification = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.formType == FormType.createEvent) {
      event = EventLongForm(responseStatus: ResponseStatus.none);

      event.participants = [];
      event.remindAt = [];
    } else {
      event = widget.event!;

      _restoreData();
    }

    prepareUserCheckboxList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.formType == FormType.createEvent
            ? "Etkinlik ekle"
            : "Etkinliği düzenle"),
        actions: [
          IconButton(
            onPressed: loading || isSaving ? null : routeSaveAction,
            icon: const Icon(Icons.save_outlined),
            tooltip: "Etkinliği kaydet",
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: loading || isSaving
            ? const Center(child: CircularProgressIndicator())
            : _getListBody(),
      ),
    );
  }

  void _restoreData() {
    controllerEventName.value = TextEditingValue(text: event.name!);
    controllerEventType.value = TextEditingValue(text: event.type!);

    if (event.remindAt!.isNotEmpty) {
      controllerEventNotification.value = TextEditingValue(
        text: event.remindAt![0].toString(),
      );
    }

    setState(() {
      date = event.startsAt!;
      timeStart = TimeOfDay.fromDateTime(event.startsAt!);
      timeEnd = TimeOfDay.fromDateTime(event.endsAt!);
    });
  }

  Widget _getListBody() {
    final eventNameField = TextField(
      decoration: const InputDecoration(
        labelText: "Etkinlik adı",
        prefixIcon: Icon(Icons.event_rounded),
      ),
      controller: controllerEventName,
    );

    final eventTypeField = TextField(
      decoration: const InputDecoration(
        labelText: "Etkinlik türü",
        prefixIcon: Icon(Icons.category_outlined),
      ),
      controller: controllerEventType,
    );

    Widget notifyTextField = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.schedule_rounded),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            controller: controllerEventNotification,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 16),
        const Text("dakika önce"),
      ],
    );

    int participantCount =
        event.participants != null ? event.participants!.length : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ListBody(
        children: [
          const InfoPlaceholder(
            icon: Icon(Icons.event_note_rounded),
            title: "Ad ve Tür",
          ),
          const SizedBox(height: 32),
          eventNameField,
          const SizedBox(height: 32),
          eventTypeField,
          const SizedBox(height: 32),
          const InfoPlaceholder(
            icon: Icon(Icons.schedule_rounded),
            title: "Tarih ve Zaman",
          ),
          const SizedBox(height: 32),
          DatePickerCard(
            time: date,
            onTap: pickDate,
          ),
          const SizedBox(height: 32),
          TimePickerCard(
            start: timeStart,
            end: timeEnd,
            onTapToStart: () => pickTime(isStartingAt: true),
            onTapToEnd: () => pickTime(isStartingAt: false),
          ),
          const SizedBox(height: 32),
          const InfoPlaceholder(
            icon: Icon(Icons.groups_outlined),
            title: "Katılımcılar",
          ),
          const SizedBox(height: 32),
          ParticipantsCard(
            participantCount: participantCount,
            onTap: () => goToAddParticipantsScreen(context),
          ),
          const SizedBox(height: 32),
          const InfoPlaceholder(
            icon: Icon(Icons.alarm_rounded),
            title: "Bildirim",
          ),
          const SizedBox(height: 32),
          notifyTextField,
        ],
      ),
    );
  }

  Future<void> prepareUserCheckboxList() async {
    for (final UserNonResponse user in await SUser.userList) {
      userCheckData.add(UserCheckboxData(user: user));
    }

    // Check the boxes of users that has been participating
    // if we're editing an existing event
    event.participants?.forEach((participantId) {
      final index = userCheckData.indexWhere(
        (checkData) => checkData.user.userId == participantId,
      );

      if (index != -1) userCheckData[index].checked = true;
    });

    // Remove our user from this list
    FullUser user = await SUser.user;
    int removalIndex = -1;

    for (int i = 0; i < userCheckData.length; i++) {
      if (userCheckData[i].user.userId == user.userId!) {
        removalIndex = i;
        break;
      }
    }

    if (removalIndex != -1) userCheckData.removeAt(removalIndex);

    setState(() {
      loading = false;
    });
  }

  Future<void> pickDate() async {
    date = await getDate(context);

    if (context.mounted) {
      setState(() {});
    }
  }

  Future<void> pickTime({required bool isStartingAt}) async {
    final picked = await getTime(context);

    if (isStartingAt) {
      if (picked != null) timeStart = picked;
    } else {
      if (picked != null) timeEnd = picked;
    }

    if (context.mounted) {
      setState(() {});
    }
  }

  void routeSaveAction() {
    if (widget.formType == FormType.createEvent) {
      pageCreateEvent();
    } else {
      pageModifyEvent();
    }
  }

  Future<void> pageCreateEvent() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    bool prepareStatus = await _prepareData();

    if (prepareStatus == false) {
      if (context.mounted) {
        setState(() {
          isSaving = false;
        });
      }

      return;
    }

    String? newEventId;

    if (context.mounted) {
      newEventId = await createEvent(context: context, event: event);

      setState(() {
        isSaving = false;
      });
    }

    if (newEventId != null) {
      EventFetchingBroadcaster.i.triggerFetch();

      if (event.remindAt!.isNotEmpty) {
        await NotificationService.i.scheduleNotification(
          eventId: newEventId,
          eventName: event.name!,
          startsAt: event.startsAt!,
          remindAt: event.remindAt![0],
        );
      }

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> pageModifyEvent() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    bool prepareStatus = await _prepareData();

    if (prepareStatus == false) {
      if (context.mounted) {
        setState(() {
          isSaving = false;
        });
      }

      return;
    }

    bool operationSuccess = false;

    if (context.mounted) {
      operationSuccess = await modifyEvent(context: context, event: event);
    }

    if (context.mounted) {
      isSaving = false;
    }

    if (operationSuccess) {
      EventFetchingBroadcaster.i.triggerFetch();
      await NotificationService.i.cancelNotification(eventId: event.eventId!);

      if (event.remindAt!.isNotEmpty) {
        await NotificationService.i.scheduleNotification(
          eventId: event.eventId!,
          eventName: event.name!,
          startsAt: event.startsAt!,
          remindAt: event.remindAt![0],
        );
      }

      if (context.mounted) {
        Navigator.of(context).pop(event);
      }
    }
  }

  Future<bool> _prepareData() async {
    event.name = controllerEventName.text;
    event.type = controllerEventType.text;

    event.startsAt = date?.copyWith(
      hour: timeStart?.hour,
      minute: timeStart?.minute,
    );

    event.endsAt = date?.copyWith(
      hour: timeEnd?.hour,
      minute: timeEnd?.minute,
    );

    final notificationField = controllerEventNotification.text;

    if (notificationField != "") {
      try {
        event.remindAt = [int.parse(controllerEventNotification.text)];
      } on FormatException {
        await showWarningPopup(
          context: context,
          title: "Geçersiz bildirim girişi",
          content: [const Text(invalidNotificationInputWarning)],
        );

        return false;
      }
    }

    return true;
  }

  Future<void> goToAddParticipantsScreen(BuildContext context) async {
    final List<UserCheckboxData>? users = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return AddParticipantsScreen(users: userCheckData);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
      ),
    );

    if (users == null) return;

    final participants = <String>[];

    for (final user in userCheckData) {
      if (user.checked) participants.add(user.user.userId);
    }

    setState(() {
      event.participants = participants;
    });
  }

  @override
  void dispose() {
    controllerEventName.dispose();
    controllerEventNotification.dispose();
    controllerEventType.dispose();

    super.dispose();
  }
}
