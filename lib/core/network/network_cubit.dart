import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late StreamSubscription<InternetConnectionStatus>
      _internetConnectionSubscription;

  NetworkCubit() : super(NetworkInitial()) {
    _monitorConnection();
  }

  void _monitorConnection() {
    // Listen to device connectivity changes (Wifi, Mobile, None)
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      // When connectivity changes, check for actual internet access
      _checkInternetConnection();
    });

    // Also listen directly to InternetConnectionChecker for more granular updates
    _internetConnectionSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        emit(NetworkConnected());
      } else {
        emit(NetworkDisconnected());
      }
    });
  }

  Future<void> _checkInternetConnection() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (hasConnection) {
      emit(NetworkConnected());
    } else {
      emit(NetworkDisconnected());
    }
  }

  // Method to manually re-check (e.g., from retry button)
  Future<void> checkConnection() async {
    emit(NetworkChecking());
    // Artificial delay for better UX (so the spinner doesn't just flash)
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkInternetConnection();
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    _internetConnectionSubscription.cancel();
    return super.close();
  }
}
