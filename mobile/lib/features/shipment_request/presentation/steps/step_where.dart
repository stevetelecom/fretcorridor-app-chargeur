import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/shipment_providers.dart';

/// Etape "Où" : adresses de collecte et de destination. Les coordonnees
/// sont saisies manuellement en V1 (voir note de simplification du plan) -
/// validees numeriquement pour rester dans des bornes GPS plausibles.
class StepWhere extends ConsumerWidget {
  const StepWhere({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(shipmentDraftProvider);
    final notifier = ref.read(shipmentDraftProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Collecte', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: draft.pickupAddress,
            decoration: const InputDecoration(
              labelText: 'Adresse de collecte',
              prefixIcon: Icon(Icons.trip_origin),
            ),
            maxLength: 255,
            onChanged: (value) => notifier.update((d) => d.copyWith(pickupAddress: value)),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: draft.pickupLat?.toString(),
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed >= -90 && parsed <= 90) {
                      notifier.update((d) => d.copyWith(pickupLat: parsed));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: draft.pickupLng?.toString(),
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed >= -180 && parsed <= 180) {
                      notifier.update((d) => d.copyWith(pickupLng: parsed));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Destination', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: draft.destinationAddress,
            decoration: const InputDecoration(
              labelText: 'Adresse de destination',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            maxLength: 255,
            onChanged: (value) => notifier.update((d) => d.copyWith(destinationAddress: value)),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: draft.destinationLat?.toString(),
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed >= -90 && parsed <= 90) {
                      notifier.update((d) => d.copyWith(destinationLat: parsed));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: draft.destinationLng?.toString(),
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed >= -180 && parsed <= 180) {
                      notifier.update((d) => d.copyWith(destinationLng: parsed));
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
