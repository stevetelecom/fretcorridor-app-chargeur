import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models/shipment_tracking.dart';
import '../providers/tracking_providers.dart';

/// Ecran de suivi (UC-MKT-03 / UC-EXE-03 partie client). Affiche la
/// chronologie d'etats, la derniere position connue (avec son age, pas une
/// carte pour l'instant - flutter_map arrivera au polish si le temps le
/// permet, le plan ne l'impose pas pour ce Sprint) et la preuve de
/// livraison une fois le statut LIVREE atteint.
class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key, required this.shipmentRequestId});

  final String shipmentRequestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync = ref.watch(trackingProvider(shipmentRequestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi du transport')),
      body: trackingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Impossible de charger le suivi. Tirez pour rafraîchir.',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        data: (tracking) => RefreshIndicator(
          // Pas de websocket/polling automatique dans ce perimetre solo -
          // le chargeur rafraichit manuellement (geste standard Flutter,
          // pas de surprise UX).
          onRefresh: () => ref.refresh(trackingProvider(shipmentRequestId).future),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _StatusTimeline(history: tracking.statusHistory, currentStatus: tracking.currentStatus),
              if (tracking.lastPosition != null) ...[
                const SizedBox(height: 24),
                _LastPositionCard(position: tracking.lastPosition!),
              ],
              if (tracking.deliveryProof != null) ...[
                const SizedBox(height: 24),
                _DeliveryProofCard(proof: tracking.deliveryProof!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Libelle FR + icone Material pour chaque statut - centralise ici pour
/// eviter de dupliquer ce mapping dans plusieurs widgets.
class _StatusInfo {
  const _StatusInfo(this.label, this.icon);
  final String label;
  final IconData icon;
}

const Map<String, _StatusInfo> _statusInfos = {
  'BROUILLON': _StatusInfo('Brouillon', Icons.edit_note),
  'PUBLIEE': _StatusInfo('Demande publiée', Icons.publish_outlined),
  'OFFRE_RECUE': _StatusInfo('Offres reçues', Icons.local_offer_outlined),
  'ACCEPTEE': _StatusInfo('Offre acceptée', Icons.check_circle_outline),
  'EN_COURS': _StatusInfo('Transport en cours', Icons.local_shipping_outlined),
  'LIVREE': _StatusInfo('Livrée', Icons.task_alt),
  'ANNULEE': _StatusInfo('Annulée', Icons.cancel_outlined),
};

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.history, required this.currentStatus});

  final List<ShipmentStatusHistoryEntry> history;
  final String currentStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chronologie', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          for (int i = 0; i < history.length; i++)
            _TimelineStep(
              entry: history[i],
              isLast: i == history.length - 1,
              isCurrent: history[i].status == currentStatus,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.entry, required this.isLast, required this.isCurrent});

  final ShipmentStatusHistoryEntry entry;
  final bool isLast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final info = _statusInfos[entry.status] ?? const _StatusInfo('Statut inconnu', Icons.help_outline);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primary : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(info.icon, size: 16, color: Colors.white),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                  Text(_formatDateTime(entry.occurredAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastPositionCard extends StatelessWidget {
  const _LastPositionCard({required this.position});

  final LastPosition position;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dernière position connue', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text('${position.lat.toStringAsFixed(4)}, ${position.lng.toStringAsFixed(4)}'),
                Text(_formatAge(position.ageSeconds),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryProofCard extends StatelessWidget {
  const _DeliveryProofCard({required this.proof});

  final DeliveryProof proof;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Preuve de livraison', style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              proof.photoUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              // errorBuilder : l'URL de preuve vient de l'admin (saisie
              // manuelle), une image cassee ne doit jamais faire planter
              // l'ecran chargeur.
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey.shade100,
                child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Livrée le ${_formatDateTime(proof.deliveredAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year} à ${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');

String _formatAge(int ageSeconds) {
  if (ageSeconds < 60) return 'Il y a quelques secondes';
  if (ageSeconds < 3600) return 'Il y a ${(ageSeconds / 60).floor()} min';
  if (ageSeconds < 86400) return 'Il y a ${(ageSeconds / 3600).floor()} h';
  return 'Il y a ${(ageSeconds / 86400).floor()} j';
}
