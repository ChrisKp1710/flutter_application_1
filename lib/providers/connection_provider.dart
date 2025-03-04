import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectionStatusProvider =
    StateNotifierProvider<ConnectionStatusNotifier, bool>(
      (ref) => ConnectionStatusNotifier(),
    );

class ConnectionStatusNotifier extends StateNotifier<bool> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final Connectivity _connectivity =
      Connectivity(); // ✅ Istanziato correttamente

  ConnectionStatusNotifier() : super(true) {
    _monitorConnection();
  }

  void _monitorConnection() {
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      // ✅ Se almeno un tipo di connessione è disponibile, siamo online
      state =
          results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
