import 'package:dio/dio.dart';
import 'models/shipment_tracking.dart';

class TrackingApi {
  TrackingApi(this._dio);

  final Dio _dio;

  Future<ShipmentTracking> get(String shipmentRequestId) async {
    final response = await _dio.get('/api/shipment-requests/$shipmentRequestId/tracking');
    return ShipmentTracking.fromJson(response.data);
  }
}
