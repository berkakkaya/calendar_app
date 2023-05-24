import 'package:calendar_app/models/response_status.dart';

class EventShortForm {
  final ResponseStatus status;

  String? eventId;
  String? name;
  String? type;
  int? startsAt;
  int? endsAt;

  EventShortForm({
    required this.status,
    this.eventId,
    this.name,
    this.type,
    this.startsAt,
    this.endsAt,
  });

  EventShortForm.fromJson(this.status, Map<String, dynamic> json) {
    eventId = json['_id'];
    name = json['name'];
    type = json['type'];
    startsAt = json['starts_at'];
    endsAt = json['ends_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['_id'] = eventId;
    data['name'] = name;
    data['type'] = type;
    data['starts_at'] = startsAt;
    data['ends_at'] = endsAt;

    return data;
  }
}

class EventLongForm {
  final ResponseStatus status;

  String? eventId;
  String? name;
  String? type;
  String? createdBy;
  List<String>? participants;
  int? startsAt;
  int? endsAt;
  List<int>? remindAt;

  EventLongForm({
    required this.status,
    this.eventId,
    this.name,
    this.type,
    this.createdBy,
    this.participants,
    this.startsAt,
    this.endsAt,
    this.remindAt,
  });

  EventLongForm.fromJson(this.status, Map<String, dynamic> json) {
    eventId = json['_id'];
    name = json['name'];
    type = json['type'];
    createdBy = json['created_by'];
    participants = json['participants'].cast<String>();
    startsAt = json['starts_at'];
    endsAt = json['ends_at'];
    remindAt = json['remind_at'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = eventId;
    data['name'] = name;
    data['type'] = type;
    data['created_by'] = createdBy;
    data['participants'] = participants;
    data['starts_at'] = startsAt;
    data['ends_at'] = endsAt;
    data['remind_at'] = remindAt;
    return data;
  }
}