import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/widgets/datetime_picker_card.dart';
import 'package:calendar_app/widgets/info_placeholder.dart';
import 'package:calendar_app/widgets/participants_card.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

    if (widget.formType == FormType.createEvent) {
      event = EventLongForm(responseStatus: ResponseStatus.none);
      return;
    }

    event = EventLongForm.fromJson(ResponseStatus.none, widget.event!.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final eventNameField = TextField(
      decoration: const InputDecoration(
        labelText: "Etkinlik adı",
        prefixIcon: Icon(Icons.event_rounded),
      ),
      onChanged: (text) => event.name = text,
    );

    final eventTypeField = TextField(
      decoration: const InputDecoration(
        labelText: "Etkinlik türü",
        prefixIcon: Icon(Icons.category_outlined),
      ),
      onChanged: (text) => event.type = text,
    );

    const notifyTextField = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.schedule_rounded),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(width: 16),
        Text("dakika önce"),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.formType == FormType.createEvent
            ? "Etkinlik ekle"
            : "Etkinliği düzenle"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.save_outlined),
            tooltip: "Etkinliği kaydet",
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          reverse: true,
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
                onTap: () => pickDateAndTime(isStartingAt: true),
              ),
              const SizedBox(height: 32),
              DatePickerCard(
                isStartingAt: false,
                time: event.endsAt,
                onTap: () => pickDateAndTime(isStartingAt: false),
              ),
              const SizedBox(height: 32),
              const InfoPlaceholder(
                icon: Icon(Icons.groups_outlined),
                title: "Katılımcılar",
              ),
              const SizedBox(height: 32),
              const ParticipantsCard(participantCount: 0),
              const SizedBox(height: 32),
              const InfoPlaceholder(
                icon: Icon(Icons.alarm_rounded),
                title: "Bildirim",
              ),
              const SizedBox(height: 32),
              notifyTextField,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickDateAndTime({required bool isStartingAt}) async {
    DateTime nowDate = DateTime.now();
    TimeOfDay nowTime = TimeOfDay.now();

    DateTime? date;
    TimeOfDay? time;

    date = await showDatePicker(
      context: context,
      initialDate: nowDate,
      firstDate: nowDate,
      lastDate: nowDate.add(const Duration(days: 365 * 5)),
      helpText: "Tarih seçin",
      cancelText: "İptal et",
      confirmText: "Kaydet",
      errorFormatText: "Geçersiz tarih formatı",
      errorInvalidText: "Geçersiz tarih girişi",
      fieldLabelText: "Tarih",
    );

    if (date == null) return;

    if (context.mounted) {
      time = await showTimePicker(
        context: context,
        initialTime: nowTime,
        helpText: "Zaman seçin",
        cancelText: "İptal et",
        confirmText: "Kaydet",
        hourLabelText: "Saat",
        minuteLabelText: "Dakika",
        errorInvalidText: "Geçersiz giriş",
      );
    }

    if (time == null) return;

    date = date.copyWith(hour: time.hour, minute: time.minute);

    setState(() {
      if (isStartingAt) {
        event.startsAt = date;
      } else {
        event.endsAt = date;
      }
    });
  }
}
