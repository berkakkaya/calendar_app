import 'package:calendar_app/consts/illustrations.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/user.dart';
import 'package:calendar_app/screens/events/add_modify_event_screen.dart';
import 'package:calendar_app/utils/animations/sliding_scaled_page_transition.dart';
import 'package:calendar_app/utils/api.dart';
import 'package:calendar_app/utils/checks.dart';
import 'package:calendar_app/utils/event_fetching_broadcaster.dart';
import 'package:calendar_app/utils/formatter.dart';
import 'package:calendar_app/widgets/event_card.dart';
import 'package:calendar_app/widgets/popups.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<EventShortForm> events = [];
  List<UserNonResponse> users = [];

  bool fetching = false;
  bool addEventLock = false;

  @override
  void initState() {
    super.initState();
    fetchData(fetchEvents: true);

    EventFetchingBroadcaster.i.stream.listen((event) {
      fetchData(fetchEvents: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hoşgeldiniz"),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_rounded),
            tooltip: "Yenile",
            onPressed: fetching ? null : () => fetchData(fetchEvents: true),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: "Profil sayfası",
            onPressed: () {},
          ),
        ],
      ),
      body: events.isEmpty
          ? const _EmptyEventView()
          : _EventView(eventsSorted: events),
      floatingActionButton: FloatingActionButton(
        onPressed: (addEventLock || fetching)
            ? null
            : () => goToAddEventScreen(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> fetchData({
    bool fetchEvents = false,
  }) async {
    if (fetching) return;

    setState(() {
      fetching = true;
    });

    if (fetchEvents && context.mounted) {
      final EventList rawEvents = await _fetchEvents();

      if (rawEvents.responseStatus == ResponseStatus.success) {
        events = rawEvents.events;
        events.sort((a, b) => a.startsAt!.compareTo(b.startsAt!));
      }
    }

    setState(() {
      fetching = false;
    });
  }

  Future<EventList> _fetchEvents() async {
    late EventList response;

    bool authStatus = await checkAuthenticationStatus(
      context: context,
      apiCall: () async {
        response = await ApiManager.getEventList();
        return response;
      },
    );

    if (!authStatus) {
      return EventList(
        responseStatus: ResponseStatus.authorizationError,
      );
    }

    if (response.responseStatus == ResponseStatus.serverError) {
      if (context.mounted) {
        await showWarningPopup(
          context: context,
          title: "Sunucu hatası",
          content: [
            const Text(serverError),
          ],
        );
      }

      return EventList(responseStatus: ResponseStatus.serverError);
    }

    return response;
  }

  Future<void> goToAddEventScreen(BuildContext context) async {
    await Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return const AddModifyEventScreen(
          formType: FormType.createEvent,
        );
      },
      transitionsBuilder: SlidingScaledPageTransition.generate,
      barrierColor: SlidingScaledPageTransition.barrierColor,
      transitionDuration: SlidingScaledPageTransition.duration,
      reverseTransitionDuration: SlidingScaledPageTransition.duration,
    ));

    if (context.mounted) {
      await fetchData(fetchEvents: true);
    }
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
  final List<EventShortForm> eventsSorted;

  const _EventView({required this.eventsSorted});

  @override
  Widget build(BuildContext context) {
    final List<Widget> eventList = groupEvents(context, eventsSorted);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 96),
      itemCount: eventList.length,
      itemBuilder: (context, index) => eventList[index],
      separatorBuilder: (context, index) => const SizedBox(height: 32),
    );
  }
}

List<Widget> groupEvents(
  BuildContext context,
  List<EventShortForm> eventsSorted,
) {
  List<EventShortForm> eventsLocal = List.from(eventsSorted);

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
