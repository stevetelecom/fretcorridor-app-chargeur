import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/session_provider.dart';
import '../data/draft_storage_service.dart';
import '../data/models/package_catalog_item.dart';
import '../data/models/shipment_request_draft.dart';
import '../data/shipment_api.dart';

final draftStorageProvider = Provider((ref) => DraftStorageService());

final shipmentApiProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider);
  return ShipmentApi(dio);
});

/// Charge une fois le catalogue (~15 items, change rarement) - pas de
/// rafraichissement automatique, un pull-to-refresh simple suffit si besoin
/// plus tard.
final catalogProvider = FutureProvider<List<PackageCatalogItem>>((ref) async {
  return ref.read(shipmentApiProvider).getCatalog();
});

/// Etat du brouillon en cours de saisie. Chaque modification est
/// immediatement persistee (Hive) pour survivre a une fermeture d'appli ou
/// une coupure reseau en plein assistant (UC-MKT-01 E4).
class ShipmentDraftNotifier extends Notifier<ShipmentRequestDraft> {
  @override
  ShipmentRequestDraft build() {
    _loadPersisted();
    return const ShipmentRequestDraft();
  }

  Future<void> _loadPersisted() async {
    final saved = await ref.read(draftStorageProvider).load();
    if (saved != null) state = saved;
  }

  void update(ShipmentRequestDraft Function(ShipmentRequestDraft) updater) {
    state = updater(state);
    ref.read(draftStorageProvider).save(state);
  }

  Future<void> reset() async {
    state = const ShipmentRequestDraft();
    await ref.read(draftStorageProvider).clear();
  }
}

final shipmentDraftProvider =
    NotifierProvider<ShipmentDraftNotifier, ShipmentRequestDraft>(ShipmentDraftNotifier.new);

/// Soumission finale - separee du draft pour exposer un etat de chargement/
/// erreur propre a l'action "Publier", sans polluer l'etat du formulaire.
class ShipmentSubmissionNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async => null;

  Future<void> submit() async {
    final draft = ref.read(shipmentDraftProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(shipmentApiProvider).create(draft));
    if (!state.hasError) {
      await ref.read(shipmentDraftProvider.notifier).reset();
    }
  }
}

final shipmentSubmissionProvider =
    AsyncNotifierProvider<ShipmentSubmissionNotifier, Map<String, dynamic>?>(
        ShipmentSubmissionNotifier.new);
