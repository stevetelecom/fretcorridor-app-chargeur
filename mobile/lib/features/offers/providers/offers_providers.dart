import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/session_provider.dart';
import '../data/models/offer.dart';
import '../data/offers_api.dart';

final offersApiProvider = Provider((ref) => OffersApi(ref.watch(dioClientProvider)));

/// Liste des offres pour une demande donnee - family car parametree par
/// shipmentRequestId (plusieurs demandes peuvent etre consultees dans la
/// meme session). autoDispose : on ne garde pas ce cache une fois l'ecran
/// quitte, les offres pouvant changer de statut cote serveur entre deux
/// visites.
final offersProvider =
    FutureProvider.autoDispose.family<List<Offer>, String>((ref, shipmentRequestId) async {
  return ref.read(offersApiProvider).list(shipmentRequestId);
});

class OfferAcceptanceNotifier extends AsyncNotifier<Offer?> {
  @override
  Future<Offer?> build() async => null;

  Future<void> accept(String shipmentRequestId, String offerId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(offersApiProvider).accept(shipmentRequestId, offerId));
  }
}

final offerAcceptanceProvider =
    AsyncNotifierProvider<OfferAcceptanceNotifier, Offer?>(OfferAcceptanceNotifier.new);
