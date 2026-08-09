import 'package:dio/dio.dart';
import 'models/offer.dart';

class OffersApi {
  OffersApi(this._dio);

  final Dio _dio;

  Future<List<Offer>> list(String shipmentRequestId) async {
    final response = await _dio.get('/api/shipment-requests/$shipmentRequestId/offers');
    return (response.data as List).map((json) => Offer.fromJson(json)).toList();
  }

  Future<Offer> accept(String shipmentRequestId, String offerId) async {
    final response = await _dio
        .post('/api/shipment-requests/$shipmentRequestId/offers/$offerId/accept');
    return Offer.fromJson(response.data);
  }
}
