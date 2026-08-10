/// Une entree de la chronologie d'etats (correspond a
/// ShipmentStatusHistoryEntry cote backend). Le statut reste une String
/// brute ici (pas d'enum Dart) : le libelle affichable est derive dans
/// l'UI via _statusLabel, pour ne pas dupliquer la logique de mapping
/// dans le modele de donnees.
class ShipmentStatusHistoryEntry {
  ShipmentStatusHistoryEntry({required this.status, required this.occurredAt});

  final String status;
  final DateTime occurredAt;

  factory ShipmentStatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ShipmentStatusHistoryEntry(
        status: json['status'],
        occurredAt: DateTime.parse(json['occurredAt']),
      );
}

/// Derniere position connue. ageSeconds vient du backend (calcule
/// serveur, jamais recalcule cote client - evite tout decalage d'horloge
/// telephone/serveur, voir LastPositionResponse cote backend).
class LastPosition {
  LastPosition({
    required this.lat,
    required this.lng,
    required this.recordedAt,
    required this.ageSeconds,
  });

  final double lat;
  final double lng;
  final DateTime recordedAt;
  final int ageSeconds;

  factory LastPosition.fromJson(Map<String, dynamic> json) => LastPosition(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        recordedAt: DateTime.parse(json['recordedAt']),
        ageSeconds: json['ageSeconds'],
      );
}

class DeliveryProof {
  DeliveryProof({required this.photoUrl, required this.deliveredAt});

  final String photoUrl;
  final DateTime deliveredAt;

  factory DeliveryProof.fromJson(Map<String, dynamic> json) => DeliveryProof(
        photoUrl: json['photoUrl'],
        deliveredAt: DateTime.parse(json['deliveredAt']),
      );
}

/// Reponse complete de GET /api/shipment-requests/{id}/tracking.
/// lastPosition et deliveryProof sont nullables : rien n'a encore ete
/// injecte par l'admin tant que la demande n'est pas EN_COURS / LIVREE.
class ShipmentTracking {
  ShipmentTracking({
    required this.currentStatus,
    required this.statusHistory,
    this.lastPosition,
    this.deliveryProof,
  });

  final String currentStatus;
  final List<ShipmentStatusHistoryEntry> statusHistory;
  final LastPosition? lastPosition;
  final DeliveryProof? deliveryProof;

  factory ShipmentTracking.fromJson(Map<String, dynamic> json) => ShipmentTracking(
        currentStatus: json['currentStatus'],
        statusHistory: (json['statusHistory'] as List)
            .map((e) => ShipmentStatusHistoryEntry.fromJson(e))
            .toList(),
        lastPosition:
            json['lastPosition'] != null ? LastPosition.fromJson(json['lastPosition']) : null,
        deliveryProof:
            json['deliveryProof'] != null ? DeliveryProof.fromJson(json['deliveryProof']) : null,
      );
}
