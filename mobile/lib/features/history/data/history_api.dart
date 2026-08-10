import 'package:dio/dio.dart';
import 'models/shipment_request.dart';

class HistoryApi {
  HistoryApi(this._dio);

  final Dio _dio;

  Future<List<ShipmentRequest>> list() async {
    final response = await _dio.get('/api/shipment-requests');
    return (response.data as List).map((json) => ShipmentRequest.fromJson(json)).toList();
  }

  /// UC historique "Refaire cet envoi" (Sprint 6) - republie a l'identique,
  /// seule la date d'enlevement change (voir RepublishRequest cote backend,
  /// contrainte @FutureOrPresent qui interdit de reutiliser l'ancienne date).
  Future<ShipmentRequest> republish(String shipmentRequestId, DateTime newPickupDate) async {
    final response = await _dio.post(
      '/api/shipment-requests/$shipmentRequestId/republish',
      data: {'requestedPickupDate': _formatDate(newPickupDate)},
    );
    return ShipmentRequest.fromJson(response.data);
  }

  // LocalDate cote backend attend YYYY-MM-DD, pas un DateTime ISO complet.
  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
