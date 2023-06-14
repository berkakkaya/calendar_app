import 'package:calendar_app/models/base_response.dart';
import 'package:calendar_app/models/enums.dart';

class EventShortForm {
  String? eventId;
  String? name;
  String? type;
  DateTime? startsAt;
  DateTime? endsAt;

  EventShortForm({
    this.eventId,
    this.name,
    this.type,
    this.startsAt,
    this.endsAt,
  });

  EventShortForm.fromJson(Map<String, dynamic> json) {
    eventId = json['_id'];
    name = json['name'];
    type = json['type'];
    startsAt = DateTime.fromMillisecondsSinceEpoch(
      int.parse(json["starts_at"]),
    );
    endsAt = DateTime.fromMillisecondsSinceEpoch(
      int.parse(json["ends_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['_id'] = eventId;
    data['name'] = name;
    data['type'] = type;
    data['starts_at'] = startsAt!.millisecondsSinceEpoch;
    data['ends_at'] = endsAt!.millisecondsSinceEpoch;

    return data;
  }
}

class EventLongForm implements BaseResponse {
  @override
  final ResponseStatus responseStatus;

  String? eventId;
  String? name;
  String? type;
  String? createdBy;
  List<String>? participants;
  DateTime? startsAt;
  DateTime? endsAt;
  List<int>? remindAt;

  EventLongForm({
    required this.responseStatus,
    this.eventId,
    this.name,
    this.type,
    this.createdBy,
    this.participants,
    this.startsAt,
    this.endsAt,
    this.remindAt,
  });

  bool isThereAnyReqiredNull() {
    if ([
      name,
      type,
      startsAt,
      endsAt,
    ].contains(null)) return true;

    return false;
  }

  EventLongForm.fromJson(this.responseStatus, Map<String, dynamic> json) {
    eventId = json['_id'];
    name = json['name'];
    type = json['type'];
    createdBy = json['created_by'];
    participants = json['participants'].cast<String>();
    startsAt = DateTime.fromMillisecondsSinceEpoch(
      int.parse(json["starts_at"]),
    );
    endsAt = DateTime.fromMillisecondsSinceEpoch(
      int.parse(json["ends_at"]),
    );
    remindAt = json['remind_at'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['_id'] = eventId!;
    data['name'] = name!;
    data['type'] = type!;
    data['created_by'] = createdBy!;
    data['participants'] = participants!;
    data['starts_at'] = startsAt!.millisecondsSinceEpoch;
    data['ends_at'] = endsAt!.millisecondsSinceEpoch;
    data['remind_at'] = remindAt!;

    return data;
  }
}

class EventList implements BaseResponse {
  @override
  final ResponseStatus responseStatus;
  final List<EventShortForm> events = [];

  EventList({
    required this.responseStatus,
    dynamic data,
  }) {
    if (data == null) return;

    for (Map<String, dynamic> event in data) {
      events.add(EventShortForm.fromJson(event));
    }
  }
}
