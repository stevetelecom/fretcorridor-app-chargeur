import 'package:dio/dio.dart';
import 'models/package_catalog_item.dart';
import 'models/shipment_request_draft.dart';

class ShipmentApi {
  ShipmentApi(this._dio);

  final Dio _dio;

  Future<List<PackageCatalogItem>> getCatalog() async {
    final response = await _dio.get('/api/package-catalog');
    return (response.data as List)
        .map((json) => PackageCatalogItem.fromJson(json))
        .toList();
  }

  /// Publie la demande. Le draft doit etre complet (draft.isComplete) avant
  /// l'appel - controle deja fait cote UI, revalide integralement cote
  /// backend (Bean Validation) qui reste la seule source de verite.
  Future<Map<String, dynamic>> create(ShipmentRequestDraft draft) async {
    final response = await _dio.post('/api/shipment-requests', data: {
      'pickupAddress': draft.pickupAddress,
      'pickupLat': draft.pickupLat,
      'pickupLng': draft.pickupLng,
      'destinationAddress': draft.destinationAddress,
      'destinationLat': draft.destinationLat,
      'destinationLng': draft.destinationLng,
      'packageCatalogItemId': draft.packageCatalogItemId,
      'quantity': draft.quantity,
      'fragile': draft.fragile,
      'requestedPickupDate': draft.requestedPickupDate!.toIso8601String().split('T').first,
      'deliveryMode': draft.deliveryMode,
      'recipientName': draft.recipientName,
      'recipientPhone': draft.recipientPhone,
    });
    return response.data;
  }
}
