import 'dart:async';
//import 'dart:ui';

import 'package:bonsoir/bonsoir.dart';

class HAMdnsDiscovery {
  final String serviceType = '_home-assistant._tcp';
  late BonsoirDiscovery _bonsoirDiscovery;

  /// The subscription object.
  //StreamSubscription<BonsoirDiscoveryEvent>? _subscription;

  HAMdnsDiscovery() {
    _bonsoirDiscovery = BonsoirDiscovery(type: serviceType);
  }

  /// Returns all discovered (and resolved) services.
  //List<ResolvedBonsoirService> get discoveredHAInstances =>
  //    List.of(_resolvedServices);

  /// Starts the Bonsoir discovery.
  Future<void> start() async {
    //if (!_bonsoirDiscovery.isStopped) {
    //  _bonsoirDiscovery.stop();
    //}

    if (!_bonsoirDiscovery.isReady) {
      await _bonsoirDiscovery.ready;
    }

    //print(_bonsoirDiscovery.isStopped);
    await _bonsoirDiscovery.start();

    //if (_bonsoirDiscovery!.eventStream != null) {
    //await for (final event in _bonsoirDiscovery!.eventStream) {}
    //}

    //_subscription = _bonsoirDiscovery!.eventStream!.listen(_onEventOccurred);
  }

  /// Stops the Bonsoir discovery.
  void stop() {
    //_subscription?.cancel();
    //_subscription = null;
    _bonsoirDiscovery.stop();
  }

  /// Triggered when a Bonsoir discovery event occurred.
  ResolvedBonsoirService resolveHA(BonsoirDiscoveryEvent event) {
    /*
    if (event.service == null || !event.isServiceResolved) {
      return null;
    }
    */
    ResolvedBonsoirService service = event.service as ResolvedBonsoirService;
    return service;
  }

  Stream<BonsoirDiscoveryEvent> found() async* {
    //await start();
    if (!_bonsoirDiscovery.isReady) {
      await _bonsoirDiscovery.ready;
    }
    final stream = _bonsoirDiscovery.eventStream;
    if (stream != null) {
      //yield* stream;

      /*
      stream.listen((BonsoirDiscoveryEvent event) {
        if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
          final svc = event.service as ResolvedBonsoirService;
          print(svc);
        }
      });
      */

      _bonsoirDiscovery.start();
      await for (BonsoirDiscoveryEvent event in stream) {
        if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
          yield event;
        }
      }

      //await _bonsoirDiscovery.start();
    }
  }
}
