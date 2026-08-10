import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/session_provider.dart';
import '../data/history_api.dart';
import '../data/models/shipment_request.dart';

final historyApiProvider = Provider((ref) => HistoryApi(ref.watch(dioClientProvider)));

// autoDispose : le statut des demandes evolue cote serveur (offres,
// paiement, livraison) - pas de cache conserve entre deux visites, meme
// raisonnement que offersProvider/trackingProvider.
final historyProvider = FutureProvider.autoDispose<List<ShipmentRequest>>((ref) async {
  return ref.read(historyApiProvider).list();
});

class RepublishNotifier extends AsyncNotifier<ShipmentRequest?> {
  @override
  Future<ShipmentRequest?> build() async => null;

  Future<void> republish(String shipmentRequestId, DateTime newPickupDate) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(historyApiProvider).republish(shipmentRequestId, newPickupDate));
  }
}

final republishProvider =
    AsyncNotifierProvider<RepublishNotifier, ShipmentRequest?>(RepublishNotifier.new);
