import 'package:animations/animations.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/models/user_checkbox_data.dart';
import 'package:calendar_app/models/user_list.dart';
import 'package:calendar_app/screens/events/add_participants_screen.dart';
import 'package:calendar_app/utils/api.dart';
import 'package:calendar_app/utils/checks.dart';
import 'package:calendar_app/utils/datetime_picking.dart';
import 'package:calendar_app/utils/event_management.dart';
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
      event = EventLongForm.fromJson(
        ResponseStatus.none,
        widget.event!.toJson(),
      );
    }

    getUserList();
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
            onTapToStart: () => _pickTime(isStartingAt: true),
            onTapToEnd: () => _pickTime(isStartingAt: false),
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

  Future<void> getUserList() async {
    late UserList userData;

    final bool isLoggedIn = await checkAuthenticationStatus(
      context: context,
      apiCall: () async {
        userData = await ApiManager.getUsersList();

        return userData;
      },
    );

    if (!isLoggedIn) return;

    if (userData.responseStatus == ResponseStatus.serverError) {
      if (context.mounted) {
        await showWarningPopup(
          context: context,
          title: "Sunucu hatası",
          content: [const Text(serverError)],
        );
      }

      return;
    }

    userData.userList?.forEach((user) {
      userCheckData.add(UserCheckboxData(user: user));
    });

    // Check the participants from the previous state
    event.participants?.forEach((participantId) {
      final index = userCheckData.indexWhere(
        (checkData) => checkData.user.userId == participantId,
      );

      if (index != -1) userCheckData[index].checked = true;
    });

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

  Future<void> _pickTime({required bool isStartingAt}) async {
    final picked = await getTime(context);

    if (isStartingAt) {
      timeStart = picked;
    } else {
      timeEnd = picked;
    }

    if (context.mounted) {
      setState(() {});
    }
  }

  void routeSaveAction() {
    if (widget.formType == FormType.createEvent) {
      pageCreateEvent();
    }

    // TODO: Connect the modify event function here
  }

  Future<void> pageCreateEvent() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

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

        if (context.mounted) {
          setState(() {
            isSaving = false;
          });
        }

        return;
      }
    }

    bool operationSuccess = false;

    if (context.mounted) {
      operationSuccess = await createEvent(context: context, event: event);

      setState(() {
        isSaving = false;
      });
    }

    if (operationSuccess && context.mounted) Navigator.of(context).pop();
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

    setState(() {
      event.participants = [];

      for (UserCheckboxData user in users) {
        if (user.checked) event.participants!.add(user.user.userId);
      }
    });
  }
}
