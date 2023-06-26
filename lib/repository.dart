import 'package:bonsoir/bonsoir.dart';
import 'package:ha_assist/discovery.dart';

class HADiscoveredRepository {
  late HAMdnsDiscovery _discovery;

  /// Contains all discovered (and resolved) services.
  final List<ResolvedBonsoirService> _resolvedServices = [];

  final Map<String, String> tokens = {};

  HADiscoveredRepository() {
    _discovery = HAMdnsDiscovery();
  }

  void start() {
    _discovery.start();
  }

  void stop() {
    _discovery.stop();
  }

  Stream<List<ResolvedBonsoirService>> find() async* {
    await for (final event in _discovery.found()) {
      ResolvedBonsoirService ha = _discovery.resolveHA(event);
      _resolvedServices.add(ha);
      yield _resolvedServices;
      /*
      ResolvedBonsoirService ha = _discovery.resolveHA(event);
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
        _resolvedServices.add(ha!);
        yield List.from(_resolvedServices);
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        _resolvedServices.remove(ha);
        yield List.from(_resolvedServices);
      }
      */
    }
  }
}
