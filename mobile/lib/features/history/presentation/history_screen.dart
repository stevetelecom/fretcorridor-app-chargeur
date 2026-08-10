import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../data/models/shipment_request.dart';
import '../providers/history_providers.dart';

/// Historique des envois (Sprint 6). Chaque carte propose "Refaire cet
/// envoi" - republie a l'identique via une modal ne demandant que la
/// nouvelle date d'enlevement (seul champ qui doit forcement changer,
/// voir RepublishRequest cote backend).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _confirmRepublish(BuildContext context, WidgetRef ref, ShipmentRequest source) async {
    final selectedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _RepublishModal(source: source),
    );

    if (selectedDate == null || !context.mounted) return;

    await ref.read(republishProvider.notifier).republish(source.id, selectedDate);
    if (!context.mounted) return;

    final result = ref.read(republishProvider);
    result.whenOrNull(
      data: (republished) {
        if (republished != null) {
          AppToast.success('Demande republiée avec succès');
          ref.invalidate(historyProvider);
          context.go('/shipment/${republished.id}/tracking');
        }
      },
      error: (error, _) => AppToast.error('Impossible de republier cette demande. Réessayez.'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des envois')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Impossible de charger l\'historique. Tirez pour rafraîchir.',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('Aucun envoi pour le moment', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(historyProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _HistoryCard(request: requests[index], onRepublish: () => _confirmRepublish(context, ref, requests[index])),
            ),
          );
        },
      ),
    );
  }
}

const Map<String, String> _statusLabels = {
  'BROUILLON': 'Brouillon',
  'PUBLIEE': 'Demande publiée',
  'OFFRE_RECUE': 'Offres reçues',
  'ACCEPTEE': 'Offre acceptée',
  'EN_COURS': 'Transport en cours',
  'LIVREE': 'Livrée',
  'ANNULEE': 'Annulée',
};

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.request, required this.onRepublish});

  final ShipmentRequest request;
  final VoidCallback onRepublish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForCategory(request.packageItem.iconName), color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(request.packageItem.label,
                    style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
              ),
              _StatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 12),
          _RouteRow(pickup: request.pickupAddress, destination: request.destinationAddress),
          const SizedBox(height: 8),
          Text(
            'Publiée le ${_formatDate(request.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onRepublish,
              icon: const Icon(Icons.replay, size: 18),
              label: const Text('Refaire cet envoi'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String iconName) {
    // iconName vient du catalogue backend (seed) - mapping defensif, une
    // valeur inconnue ne doit jamais casser l'affichage.
    const mapping = {
      'box': Icons.inventory_2_outlined,
      'document': Icons.description_outlined,
      'fragile': Icons.warning_amber_outlined,
      'furniture': Icons.chair_outlined,
      'electronics': Icons.devices_outlined,
    };
    return mapping[iconName] ?? Icons.local_shipping_outlined;
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.pickup, required this.destination});

  final String pickup;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(pickup, overflow: TextOverflow.ellipsis)),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 3),
          child: SizedBox(height: 16, child: VerticalDivider(width: 2, thickness: 2)),
        ),
        Row(
          children: [
            const Icon(Icons.location_on, size: 8, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(destination, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = _statusLabels[status] ?? status;
    final isTerminal = status == 'LIVREE' || status == 'ANNULEE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isTerminal ? Colors.grey.shade100 : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isTerminal ? Colors.grey.shade700 : AppColors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RepublishModal extends StatefulWidget {
  const _RepublishModal({required this.source});

  final ShipmentRequest source;

  @override
  State<_RepublishModal> createState() => _RepublishModalState();
}

class _RepublishModalState extends State<_RepublishModal> {
  DateTime? _selectedDate;

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
            Text('Refaire cet envoi', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Même trajet, même colis, même destinataire — choisissez juste la nouvelle date d\'enlèvement.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(_selectedDate == null
                  ? 'Choisir la date d\'enlèvement'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _selectedDate == null ? null : () => Navigator.pop(context, _selectedDate),
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

String _formatDate(DateTime dt) {
  final local = dt.toLocal();
  return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year}';
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');
