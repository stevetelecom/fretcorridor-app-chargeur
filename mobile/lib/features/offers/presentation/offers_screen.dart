import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../data/models/offer.dart';
import '../providers/offers_providers.dart';

/// Liste des offres recues pour une demande (UC-MKT-02), triees par prix
/// croissant cote backend. Chaque carte s'anime a l'apparition ; accepter
/// une offre passe par une modal de confirmation (regle CRUD du guide
/// ultime : toute action de validation se fait via modal + toast).
class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key, required this.shipmentRequestId});

  final String shipmentRequestId;

  Future<void> _confirmAccept(BuildContext context, WidgetRef ref, Offer offer) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AcceptOfferModal(offer: offer),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(offerAcceptanceProvider.notifier).accept(shipmentRequestId, offer.id);
    if (!context.mounted) return;

    final result = ref.read(offerAcceptanceProvider);
    result.whenOrNull(
      data: (accepted) {
        if (accepted != null) {
          AppToast.success('Offre acceptée — transporteur confirmé');
          ref.invalidate(offersProvider(shipmentRequestId));
          context.go('/shipment/$shipmentRequestId/payment', extra: {
            'offerId': offer.id,
            'carrierName': offer.carrierDisplayName,
            'amountXaf': offer.priceXaf,
          });
        }
      },
      error: (error, _) => AppToast.error('Impossible d\'accepter cette offre. Réessayez.'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersProvider(shipmentRequestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Offres reçues')),
      body: offersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.primary, size: 40),
                const SizedBox(height: 12),
                const Text('Impossible de charger les offres.'),
                TextButton(
                  onPressed: () => ref.invalidate(offersProvider(shipmentRequestId)),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (offers) {
          if (offers.isEmpty) {
            return const Center(child: Text('Aucune offre pour le moment.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 250 + index * 100),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: child,
                  ),
                ),
                child: _OfferCard(
                  offer: offer,
                  isBestPrice: index == 0,
                  onAccept: offer.status == 'PROPOSEE'
                      ? () => _confirmAccept(context, ref, offer)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer, required this.isBestPrice, this.onAccept});

  final Offer offer;
  final bool isBestPrice;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isBestPrice ? AppColors.primary : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.carrierDisplayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isBestPrice)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'MEILLEUR PRIX',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${offer.carrierRating.toStringAsFixed(1)}/5'),
                const SizedBox(width: 16),
                const Icon(Icons.event_outlined, size: 18, color: Colors.black45),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Enlèvement ${_formatDate(offer.estimatedPickupAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${offer.priceXaf.toStringAsFixed(0)} XAF',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (onAccept != null)
                  FilledButton(onPressed: onAccept, child: const Text('Accepter'))
                else
                  Chip(label: Text(_statusLabel(offer.status))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}';

  String _statusLabel(String status) => switch (status) {
        'ACCEPTEE' => 'Acceptée',
        'REFUSEE' => 'Non retenue',
        'EXPIREE' => 'Expirée',
        _ => status,
      };
}

class _AcceptOfferModal extends StatelessWidget {
  const _AcceptOfferModal({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Confirmer ce transporteur ?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              '${offer.carrierDisplayName} — ${offer.priceXaf.toStringAsFixed(0)} XAF\n'
              'Les autres offres seront automatiquement refusées.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirmer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
