/// Brouillon de demande, tenu en memoire (Riverpod) et serialise en JSON
/// pour Hive - resilience coupure reseau (UC-MKT-01 E4, plan §2.2). Les
/// champs restent nullables tant que l'assistant n'est pas arrive au bout :
/// un brouillon incomplet doit pouvoir etre sauvegarde sans erreur.
class ShipmentRequestDraft {
  const ShipmentRequestDraft({
    this.pickupAddress,
    this.pickupLat,
    this.pickupLng,
    this.destinationAddress,
    this.destinationLat,
    this.destinationLng,
    this.packageCatalogItemId,
    this.quantity = 1,
    this.fragile = false,
    this.requestedPickupDate,
    this.deliveryMode = 'STANDARD',
    this.recipientName,
    this.recipientPhone,
  });

  final String? pickupAddress;
  final double? pickupLat;
  final double? pickupLng;
  final String? destinationAddress;
  final double? destinationLat;
  final double? destinationLng;
  final String? packageCatalogItemId;
  final int quantity;
  final bool fragile;
  final DateTime? requestedPickupDate;
  final String deliveryMode; // STANDARD ou EXPRESS
  final String? recipientName;
  final String? recipientPhone;

  ShipmentRequestDraft copyWith({
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    String? destinationAddress,
    double? destinationLat,
    double? destinationLng,
    String? packageCatalogItemId,
    int? quantity,
    bool? fragile,
    DateTime? requestedPickupDate,
    String? deliveryMode,
    String? recipientName,
    String? recipientPhone,
  }) {
    return ShipmentRequestDraft(
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      packageCatalogItemId: packageCatalogItemId ?? this.packageCatalogItemId,
      quantity: quantity ?? this.quantity,
      fragile: fragile ?? this.fragile,
      requestedPickupDate: requestedPickupDate ?? this.requestedPickupDate,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
    );
  }

  Map<String, dynamic> toJson() => {
        'pickupAddress': pickupAddress,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'destinationAddress': destinationAddress,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'packageCatalogItemId': packageCatalogItemId,
        'quantity': quantity,
        'fragile': fragile,
        'requestedPickupDate': requestedPickupDate?.toIso8601String(),
        'deliveryMode': deliveryMode,
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
      };

  factory ShipmentRequestDraft.fromJson(Map<String, dynamic> json) => ShipmentRequestDraft(
        pickupAddress: json['pickupAddress'],
        pickupLat: (json['pickupLat'] as num?)?.toDouble(),
        pickupLng: (json['pickupLng'] as num?)?.toDouble(),
        destinationAddress: json['destinationAddress'],
        destinationLat: (json['destinationLat'] as num?)?.toDouble(),
        destinationLng: (json['destinationLng'] as num?)?.toDouble(),
        packageCatalogItemId: json['packageCatalogItemId'],
        quantity: json['quantity'] ?? 1,
        fragile: json['fragile'] ?? false,
        requestedPickupDate: json['requestedPickupDate'] != null
            ? DateTime.parse(json['requestedPickupDate'])
            : null,
        deliveryMode: json['deliveryMode'] ?? 'STANDARD',
        recipientName: json['recipientName'],
        recipientPhone: json['recipientPhone'],
      );

  /// Complet uniquement quand tous les champs requis par le backend sont
  /// renseignes - condition d'activation du bouton "Publier" a l'etape Recap.
  bool get isComplete =>
      pickupAddress != null &&
      pickupLat != null &&
      pickupLng != null &&
      destinationAddress != null &&
      destinationLat != null &&
      destinationLng != null &&
      packageCatalogItemId != null &&
      requestedPickupDate != null &&
      recipientName != null &&
      recipientName!.trim().length >= 2 &&
      recipientPhone != null;
}
