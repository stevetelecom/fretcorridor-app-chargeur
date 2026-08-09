/// Correspond au DTO PaymentResponse.
class Payment {
  Payment({
    required this.id,
    required this.shipmentRequestId,
    required this.offerId,
    required this.amountXaf,
    required this.provider,
    required this.status,
    this.providerReference,
  });

  final String id;
  final String shipmentRequestId;
  final String offerId;
  final double amountXaf;
  final String provider;
  final String? providerReference;
  final String status; // EN_ATTENTE, REUSSI, ECHOUE

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'],
        shipmentRequestId: json['shipmentRequestId'],
        offerId: json['offerId'],
        amountXaf: (json['amountXaf'] as num).toDouble(),
        provider: json['provider'],
        providerReference: json['providerReference'],
        status: json['status'],
      );
}
