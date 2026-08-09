/// Offre proposee pour une demande (correspond au DTO OfferResponse).
class Offer {
  Offer({
    required this.id,
    required this.shipmentRequestId,
    required this.carrierDisplayName,
    required this.carrierRating,
    required this.priceXaf,
    required this.estimatedPickupAt,
    required this.estimatedDeliveryAt,
    required this.status,
  });

  final String id;
  final String shipmentRequestId;
  final String carrierDisplayName;
  final double carrierRating;
  final double priceXaf;
  final DateTime estimatedPickupAt;
  final DateTime estimatedDeliveryAt;
  final String status; // PROPOSEE, ACCEPTEE, REFUSEE, EXPIREE

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        id: json['id'],
        shipmentRequestId: json['shipmentRequestId'],
        carrierDisplayName: json['carrierDisplayName'],
        carrierRating: (json['carrierRating'] as num).toDouble(),
        priceXaf: (json['priceXaf'] as num).toDouble(),
        estimatedPickupAt: DateTime.parse(json['estimatedPickupAt']),
        estimatedDeliveryAt: DateTime.parse(json['estimatedDeliveryAt']),
        status: json['status'],
      );
}
