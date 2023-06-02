import 'package:calendar_app/consts/illustrations.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/utils/formatter.dart';
import 'package:calendar_app/widgets/event_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<EventShortForm> events = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hoşgeldiniz"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: _EventView(events: [
          EventShortForm(
            name: "Deneme",
            type: "Etkinlik",
            startsAt: DateTime.now(),
            endsAt: DateTime.now().add(const Duration(hours: 2, seconds: 15)),
          ),
          EventShortForm(
            name: "Deneme 2",
            type: "Etkinlik",
            startsAt: DateTime.now().add(const Duration(minutes: 3)),
            endsAt: DateTime.now().add(const Duration(hours: 2, seconds: 15)),
          ),
          EventShortForm(
            name: "Deneme 3",
            type: "Etkinlik",
            startsAt: DateTime.now().add(const Duration(days: 3)),
            endsAt: DateTime.now().add(const Duration(days: 2, seconds: 15)),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Etkinlik ekle"),
        icon: const Icon(Icons.add_rounded),
        onPressed: () {},
      ),
    );
  }
}

class _EmptyEventView extends StatelessWidget {
  const _EmptyEventView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Expanded(
            flex: 2,
            child: emptyEventsIllustration,
          ),
          const SizedBox(height: 32),
          Text(
            "Hiçbir etkinliğiniz yok.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          const Text(
            emptyEventsDesc,
            textAlign: TextAlign.center,
          ),
          const Spacer()
        ],
      ),
    );
  }
}

class _EventView extends StatelessWidget {
  final List<EventShortForm> events;

  const _EventView({required this.events});

  @override
  Widget build(BuildContext context) {
    final List<Widget> eventList = groupEvents(context, events);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
      itemCount: eventList.length,
      itemBuilder: (context, index) => eventList[index],
      separatorBuilder: (context, index) => const SizedBox(height: 32),
    );
  }
}

List<Widget> groupEvents(BuildContext context, List<EventShortForm> events) {
  List<EventShortForm> eventsLocal = List.from(events);
  eventsLocal.sort((a, b) => a.startsAt!.compareTo(a.endsAt!));

  final now = DateTime.now();

  // Remove the past events
  eventsLocal.removeWhere((event) => now.isAfter(event.endsAt!));

  List<Widget> widgets = [];
  List<EventCard> listEventWidgets = [];

  bool foundContinuingEvent = false;
  bool foundTodaysEvent = false;

  int index;
  EventShortForm event;

  // Handle the events that happening now
  for (index = 0; index < eventsLocal.length; index++) {
    event = eventsLocal[index];

    if (event.startsAt!.isAfter(now)) break;
    foundContinuingEvent = true;

    listEventWidgets.add(EventCard(event: event, happeningNow: true));
  }

  // Remove the checked elements
  eventsLocal.removeRange(0, index);

  if (foundContinuingEvent) {
    widgets.add(Text(
      "Devam ediyor",
      style: Theme.of(context).textTheme.titleLarge,
    ));
  }

  widgets.addAll(listEventWidgets);
  listEventWidgets = [];

  // Handle the events that happening today
  for (index = 0; index < eventsLocal.length; index++) {
    event = eventsLocal[index];

    if (!doesDaysMatch(now, event.startsAt!)) break;
    foundTodaysEvent = true;

    listEventWidgets.add(EventCard(event: event));
  }

  // Remove the checked elements
  eventsLocal.removeRange(0, index);

  if (foundTodaysEvent) {
    widgets.add(Text(
      "Bugün içinde",
      style: Theme.of(context).textTheme.titleLarge,
    ));
  }

  widgets.addAll(listEventWidgets);
  listEventWidgets = [];

  // Handle the rest of events
  while (eventsLocal.isNotEmpty) {
    widgets.add(Text(
      getDateFormatter(dateFormat).format(eventsLocal.first.startsAt!),
      style: Theme.of(context).textTheme.titleLarge,
    ));

    for (index = 0; index < eventsLocal.length; index++) {
      event = eventsLocal[index];

      if (!doesDaysMatch(eventsLocal.first.startsAt!, event.startsAt!)) break;

      listEventWidgets.add(EventCard(event: event));
    }

    // Remove the checked elements
    eventsLocal.removeRange(0, index);

    widgets.addAll(listEventWidgets);
    listEventWidgets = [];
  }

  return widgets;
}

bool doesDaysMatch(DateTime a, DateTime b) {
  return a.day == b.day && a.month == b.month && a.year == b.year;
}
