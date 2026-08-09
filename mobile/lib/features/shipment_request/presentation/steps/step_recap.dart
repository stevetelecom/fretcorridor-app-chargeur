import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/shipment_providers.dart';
import '../catalog_icon.dart';

/// Recapitulatif final avant publication. Le badge "estimation, pas un prix
/// ferme" est affiche explicitement (RG-037) - jamais un chiffre unique qui
/// laisserait croire a un engagement de prix.
class StepRecap extends ConsumerWidget {
  const StepRecap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(shipmentDraftProvider);
    final catalogAsync = ref.watch(catalogProvider);

    return catalogAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Center(child: Text('Catalogue indisponible')),
      data: (catalog) {
        final selectedItem = catalog.where((i) => i.id == draft.packageCatalogItemId).firstOrNull;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RecapSection(
                icon: Icons.route_outlined,
                title: 'Trajet',
                lines: [
                  'De : ${draft.pickupAddress ?? "—"}',
                  'À : ${draft.destinationAddress ?? "—"}',
                ],
              ),
              const SizedBox(height: 16),
              _RecapSection(
                icon: selectedItem != null ? catalogIconFor(selectedItem.iconName) : Icons.inventory_2_outlined,
                title: 'Colis',
                lines: [
                  '${selectedItem?.label ?? "—"} × ${draft.quantity}',
                  if (draft.fragile) 'Marchandise fragile',
                ],
              ),
              const SizedBox(height: 16),
              _RecapSection(
                icon: Icons.event_outlined,
                title: 'Livraison',
                lines: [
                  draft.requestedPickupDate != null
                      ? 'Enlèvement le ${draft.requestedPickupDate!.day}/${draft.requestedPickupDate!.month}/${draft.requestedPickupDate!.year}'
                      : 'Date non renseignée',
                  'Mode : ${draft.deliveryMode == 'EXPRESS' ? 'Express' : 'Standard'}',
                ],
              ),
              const SizedBox(height: 16),
              _RecapSection(
                icon: Icons.person_outline,
                title: 'Destinataire',
                lines: [
                  draft.recipientName ?? '—',
                  draft.recipientPhone ?? '—',
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Le prix exact vous sera communiqué sous forme de fourchette dès la publication — jamais un montant ferme à ce stade.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              if (!draft.isComplete) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(child: Text('Certains champs obligatoires sont manquants, revenez en arrière.')),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _RecapSection extends StatelessWidget {
  const _RecapSection({required this.icon, required this.title, required this.lines});

  final IconData icon;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                ...lines.map((l) => Text(l, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
