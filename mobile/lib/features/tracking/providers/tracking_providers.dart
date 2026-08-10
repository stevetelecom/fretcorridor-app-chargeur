import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/session_provider.dart';
import '../data/models/shipment_tracking.dart';
import '../data/tracking_api.dart';

final trackingApiProvider = Provider((ref) => TrackingApi(ref.watch(dioClientProvider)));

/// family + autoDispose : meme raisonnement que offersProvider - le suivi
/// evolue cote serveur entre deux visites (position, statut), pas de cache
/// conserve une fois l'ecran quitte.
final trackingProvider =
    FutureProvider.autoDispose.family<ShipmentTracking, String>((ref, shipmentRequestId) async {
  return ref.read(trackingApiProvider).get(shipmentRequestId);
});
