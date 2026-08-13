import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../providers/payment_providers.dart';

/// Ecran de paiement (UC-PAY-01). Le montant affiche vient de l'offre
/// acceptee (passee en parametre par l'ecran precedent) - jamais recalcule
/// cote client, la source de verite reste le backend au moment du paiement
/// reel (voir PaymentService.initiate).
class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({
    super.key,
    required this.shipmentRequestId,
    required this.offerId,
    required this.carrierName,
    required this.amountXaf,
  });

  final String shipmentRequestId;
  final String offerId;
  final String carrierName;
  final double amountXaf;

  Future<void> _confirmPayment(BuildContext context, WidgetRef ref) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ConfirmPaymentModal(carrierName: carrierName, amountXaf: amountXaf),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(paymentProvider.notifier).pay(shipmentRequestId, offerId);
    if (!context.mounted) return;

    final result = ref.read(paymentProvider);
    result.whenOrNull(
      data: (payment) {
        if (payment == null) return;
        if (payment.status == 'SEQUESTRE' || payment.status == 'LIBERE') {
          AppToast.success('Paiement réussi — fonds sécurisés jusqu\'à livraison confirmée');
          context.go('/shipment/$shipmentRequestId/tracking');
        } else {
          // ECHOUE : reste sur l'ecran, le chargeur peut reessayer
          // immediatement (pas de nouvelle acceptation requise).
          AppToast.error('Paiement échoué. Réessayez ou vérifiez votre moyen de paiement.');
        }
      },
      error: (error, _) => AppToast.error('Erreur lors du paiement. Réessayez.'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentProvider);
    final failedPayment = paymentState.valueOrNull?.status == 'ECHOUE';

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Badge obligatoire (points de vigilance V1 du plan) : le
            // paiement est simule (SimulatedPaymentProvider cote backend),
            // ca doit rester visible et honnete a tout moment, demo ou pas.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Text('Mode démonstration — paiement simulé',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.amber.shade900, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 40, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text(carrierName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '${amountXaf.toStringAsFixed(0)} XAF',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            if (failedPayment) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.errorBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Le paiement précédent a échoué. Vous pouvez réessayer.'),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: paymentState.isLoading ? null : () => _confirmPayment(context, ref),
              child: paymentState.isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(failedPayment ? 'Réessayer le paiement' : 'Payer maintenant'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmPaymentModal extends StatelessWidget {
  const _ConfirmPaymentModal({required this.carrierName, required this.amountXaf});

  final String carrierName;
  final double amountXaf;

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
            Text('Confirmer le paiement ?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              '$carrierName sera réglé ${amountXaf.toStringAsFixed(0)} XAF pour ce transport.',
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
                    child: const Text('Payer'),
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
