import '../../../shipment_request/data/models/package_catalog_item.dart';

/// Correspond au DTO ShipmentRequestResponse complet (a la difference de
/// ShipmentRequestDraft, qui ne modelise que le brouillon local avant
/// publication). Utilise par l'historique (Sprint 6) et pourra servir a
/// terme d'autres ecrans ayant besoin de la demande complete telle que
/// connue du backend.
class ShipmentRequest {
  ShipmentRequest({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.packageItem,
    required this.quantity,
    required this.requestedPickupDate,
    required this.deliveryMode,
    required this.recipientName,
    required this.estimatedPriceMin,
    required this.estimatedPriceMax,
    required this.createdAt,
  });

  final String id;
  final String status;
  final String pickupAddress;
  final String destinationAddress;
  final PackageCatalogItem packageItem;
  final int quantity;
  final DateTime requestedPickupDate;
  final String deliveryMode;
  final String recipientName;
  final double estimatedPriceMin;
  final double estimatedPriceMax;
  final DateTime createdAt;

  factory ShipmentRequest.fromJson(Map<String, dynamic> json) => ShipmentRequest(
        id: json['id'],
        status: json['status'],
        pickupAddress: json['pickupAddress'],
        destinationAddress: json['destinationAddress'],
        packageItem: PackageCatalogItem.fromJson(json['packageItem']),
        quantity: json['quantity'],
        requestedPickupDate: DateTime.parse(json['requestedPickupDate']),
        deliveryMode: json['deliveryMode'],
        recipientName: json['recipientName'],
        estimatedPriceMin: (json['estimatedPriceMin'] as num).toDouble(),
        estimatedPriceMax: (json['estimatedPriceMax'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
      );
}
