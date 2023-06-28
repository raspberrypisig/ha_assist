import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ha_assist/harestapi.dart';
import 'package:ha_assist/models.dart';
import 'package:ha_assist/repository.dart';

class HAConnectionBloc extends Bloc<ConnectionStatusEvent, HAConnectionState> {
  late HADiscoveredRepository _repository;
  final HARestAPI _haApi = HARestAPI();
  final HAState _state = HAState();

  HAConnectionBloc(HADiscoveredRepository repository)
      : super(HADisconnectedState()) {
    _repository = repository;
    on<ConnectionsPageLoad>(_onConnectionsPageLoad);
    on<TokenFound>(_onTokenFound);
    on<HATalk>(_onHATalk);
    on<FindHAInstancesEvent>(_onFindHAInstances);
  }

  FutureOr<void> _onConnectionsPageLoad(
      ConnectionStatusEvent event, Emitter<HAConnectionState> emit) {
    emit(HADisconnectedState());
  }

  FutureOr<void> _onTokenFound(
      TokenFound event, Emitter<HAConnectionState> emit) async {
    debugPrint("Token found: ${event.token} for url: ${event.url}");
    var token = event.token.trim();
    bool isRestApiAvailable = await _haApi.ping(event.url, token);
    if (isRestApiAvailable) {
      _state.connection = ConnectionDetails(event.url, token);
      emit(HADiscoveredState());
      debugPrint("HA Rest API Alive");
    } else {
      emit(HADisconnectedState());
      debugPrint("HA Rest API Not Alive");
    }
  }

  FutureOr<void> _onHATalk(
      HATalk event, Emitter<HAConnectionState> emit) async {
    if (_state.apiAvailable) {
      String result = await _haApi.talkToHA(_state.connection!.homeassistant,
          _state.connection!.token, event.message);
      debugPrint(result);
    }
  }

  FutureOr<void> _onFindHAInstances(
      FindHAInstancesEvent event, Emitter<HAConnectionState> emit) async {
    await for (ResolvedBonsoirService service in _repository.find()) {
      _state.discovered.add(service);
      final ids = Set();
      _state.discovered.retainWhere((x) => ids.add(x.attributes!['base_url']));
      final newState = HADiscoveredState.fromList(_state.discovered);
      emit(newState);
    }
  }
}
