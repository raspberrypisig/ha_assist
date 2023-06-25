import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ha_assist/models.dart';
import 'package:ha_assist/repository.dart';

class HAConnectionBloc extends Bloc<ConnectionStatusEvent, HAConnectionState> {
  HAConnectionBloc(HADiscoveredRepository repository)
      : super(HADisconnectedState()) {
    on<ConnectionsPageLoad>(_onConnectionsPageLoad);
    on<TokenFound>(_onTokenFound);
  }

  FutureOr<void> _onConnectionsPageLoad(
      ConnectionStatusEvent event, Emitter<HAConnectionState> emit) {
    emit(HADisconnectedState());
  }

  FutureOr<void> _onTokenFound(
      TokenFound event, Emitter<HAConnectionState> emit) {
    debugPrint("Token found: ${event.token} for url: ${event.url}");
  }
}

class HADiscoveredBloc extends Bloc<DiscoveredEvent, HAConnectedState> {
  late HADiscoveredRepository _repository;
  List<ResolvedBonsoirService> haservices = [];

  HADiscoveredBloc(HADiscoveredRepository repository)
      : super(HAConnectedState()) {
    _repository = repository;
    on<FindHAInstancesEvent>(_onFindHAInstances);
  }

  FutureOr<void> _onFindHAInstances(
      event, Emitter<HAConnectedState> emit) async {
    print("Finding HA Instances...");
    await for (List<ResolvedBonsoirService> services in _repository.find()) {
      haservices = services;
      final newState = HAConnectedState.fromList(services);
      emit(newState);
    }
  }
}
