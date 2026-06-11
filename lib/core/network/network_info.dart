import '../services/connectivity_service.dart';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivityService);

  final ConnectivityService _connectivityService;

  @override
  Future<bool> get isConnected => _connectivityService.isConnected();
}
