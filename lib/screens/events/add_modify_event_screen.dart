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
import 'package:calendar_app/widgets/datetime_picker_card.dart';
import 'package:calendar_app/widgets/info_placeholder.dart';
import 'package:calendar_app/widgets/participants_card.dart';
import 'package:calendar_app/widgets/popups.dart';
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
            title: "Etkinlik Tarihleri",
          ),
          const SizedBox(height: 32),
          DatePickerCard(
            isStartingAt: true,
            time: event.startsAt,
            onTap: () => pickTime(isStartingAt: true),
          ),
          const SizedBox(height: 32),
          DatePickerCard(
            isStartingAt: false,
            time: event.endsAt,
            onTap: () => pickTime(isStartingAt: false),
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

  Future<void> pickTime({required bool isStartingAt}) async {
    final DateTime? picked = await pickDateAndTime(context);

    if (picked == null) return;

    setState(() {
      if (isStartingAt) {
        event.startsAt = picked;
        return;
      }

      event.endsAt = picked;
    });
  }

  void routeSaveAction() {
    if (widget.formType == FormType.createEvent) {
      createEvent();
    }

    // TODO: Connect the modify event function here
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

  Future<void> createEvent() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    event.name = controllerEventName.text;
    event.type = controllerEventType.text;

    try {
      event.remindAt = <int>[int.parse(controllerEventNotification.text)];
    } on FormatException {
      if (context.mounted) {
        showWarningPopup(
          context: context,
          title: "Geçersiz Bildirim Girişi",
          content: [const Text(invalidNotificationInputWarning)],
        );

        setState(() {
          isSaving = false;
        });
      }

      return;
    }

    // Check if any null value exists in required fields
    if (event.isThereAnyReqiredEmpty()) {
      showWarningPopup(
        context: context,
        title: "Boş giriş",
        content: [const Text(modifyEventEmptyWarning)],
      );

      setState(() {
        isSaving = false;
      });

      return;
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

      setState(() {
        isSaving = false;
      });

      return;
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
      setState(() {
        isSaving = false;
      });

      return;
    }

    if (response.responseStatus == ResponseStatus.serverError) {
      if (context.mounted) {
        await showWarningPopup(
          context: context,
          title: "Sunucu hatası",
          content: [const Text(serverError)],
        );
      }

      if (context.mounted) {
        setState(() {
          isSaving = false;
        });
      }

      return;
    }

    if (response.responseStatus == ResponseStatus.invalidRequest) {
      if (context.mounted) {
        await showWarningPopup(
          context: context,
          title: "Geçersiz giriş",
          content: [const Text(modifyEventEmptyWarning)],
        );
      }

      if (context.mounted) {
        setState(() {
          isSaving = false;
        });
      }

      return;
    }

    // Operation is successful, return to the previous screen
    if (context.mounted) {
      setState(() {
        isSaving = false;
      });

      Navigator.of(context).pop();
    }
  }
}
