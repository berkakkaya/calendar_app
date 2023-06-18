import 'dart:async';
import 'dart:developer';

/// Brodcaster that alerts if fetching the events are needed to its listeners.
///
/// This class is a singleton. You can access its instance via
/// [EventFetchingBroadcaster.i]. The stream can be listened from
/// `stream` attribute.
///
class EventFetchingBroadcaster {
  static EventFetchingBroadcaster? _i;

  /// Instance of [EventFetchingBroadcaster].
  static EventFetchingBroadcaster get i {
    if (_i != null) return _i!;

    _i = EventFetchingBroadcaster._();
    return _i!;
  }

  late Stream<void> _stream;
  Stream<void> get stream => _stream;

  late List<MultiStreamController<void>> _listeners;

  EventFetchingBroadcaster._() {
    _listeners = [];

    _stream = Stream<void>.multi((listener) {
      _listeners.add(listener);
    });
  }

  /// Broadcast all of its listeners a fetch request.
  void triggerFetch() {
    log(
      "Broadcasting the fetch request to listeners...",
      name: "EventFetchingBroadcaster",
    );

    final List<MultiStreamController<void>> markedForRemoval = [];

    for (final listener in _listeners) {
      if (!listener.isClosed) {
        listener.add(null);
      } else {
        markedForRemoval.add(listener);
      }
    }

    // Remove the listeners that have marked for removal
    for (final listener in markedForRemoval) {
      _listeners.remove(listener);
    }
  }
}
