import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:ha_assist/discovery.dart';

class HADiscoveredRepository {
  late HAMdnsDiscovery _discovery;

  /// Contains all discovered (and resolved) services.
  final List<ResolvedBonsoirService> _resolvedServices = [];

  final Map<String, String> tokens = {};

  HADiscoveredRepository() {
    _discovery = HAMdnsDiscovery((BonsoirDiscoveryEvent event) {});
  }

  void start() {
    _discovery.start();
  }

  void stop() {
    _discovery.stop();
  }

  Stream<List<ResolvedBonsoirService>> find() async* {
    StreamController<List<ResolvedBonsoirService>> streamController =
        StreamController();
    _discovery = HAMdnsDiscovery((BonsoirDiscoveryEvent event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        ResolvedBonsoirService ha = _discovery.resolveHA(event);
        _resolvedServices.add(ha);
        streamController.add(_resolvedServices);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        debugPrint("${event.service?.name} lost");
      }
    });
    _discovery.start();
    yield* streamController.stream;
  }
}
