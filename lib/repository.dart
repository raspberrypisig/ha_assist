import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:ha_assist/discovery.dart';

class HADiscoveredRepository {
  late HAMdnsDiscovery _discovery;

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

  Stream<ResolvedBonsoirService> find() async* {
    StreamController<ResolvedBonsoirService> streamController =
        StreamController();
    _discovery = HAMdnsDiscovery((BonsoirDiscoveryEvent event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        ResolvedBonsoirService ha = _discovery.resolveHA(event);
        //_resolvedServices.add(ha);
        streamController.add(ha);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        debugPrint("${event.service?.name} lost");
      }
    });
    _discovery.start();
    yield* streamController.stream;
  }
}
