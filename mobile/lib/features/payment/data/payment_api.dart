import 'package:dio/dio.dart';
import 'models/payment.dart';

class PaymentApi {
  PaymentApi(this._dio);

  final Dio _dio;

  Future<Payment> initiate(String shipmentRequestId, String offerId) async {
    final response = await _dio.post(
      '/api/shipment-requests/$shipmentRequestId/payment',
      data: {'offerId': offerId},
    );
    return Payment.fromJson(response.data);
  }
}
