import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../providers/shipment_providers.dart';

/// Etape "Quand/Comment/Qui reçoit" : date d'enlevement souhaitee, mode de
/// livraison (standard/express), coordonnees du destinataire.
class StepWhenHowWho extends ConsumerWidget {
  const StepWhenHowWho({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      ref.read(shipmentDraftProvider.notifier).update((d) => d.copyWith(requestedPickupDate: picked));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(shipmentDraftProvider);
    final notifier = ref.read(shipmentDraftProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Date d\'enlèvement souhaitée', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _pickDate(context, ref, draft.requestedPickupDate),
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              draft.requestedPickupDate != null
                  ? '${draft.requestedPickupDate!.day}/${draft.requestedPickupDate!.month}/${draft.requestedPickupDate!.year}'
                  : 'Choisir une date',
            ),
          ),
          const SizedBox(height: 24),
          Text('Mode de livraison', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'STANDARD', label: Text('Standard'), icon: Icon(Icons.local_shipping_outlined)),
              ButtonSegment(value: 'EXPRESS', label: Text('Express'), icon: Icon(Icons.bolt_outlined)),
            ],
            selected: {draft.deliveryMode},
            onSelectionChanged: (selection) =>
                notifier.update((d) => d.copyWith(deliveryMode: selection.first)),
          ),
          const SizedBox(height: 24),
          Text('Destinataire', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: draft.recipientName,
            decoration: const InputDecoration(
              labelText: 'Nom du destinataire',
              prefixIcon: Icon(Icons.person_outline),
            ),
            maxLength: 150,
            onChanged: (value) => notifier.update((d) => d.copyWith(recipientName: value)),
          ),
          IntlPhoneField(
            initialCountryCode: 'CM',
            decoration: const InputDecoration(
              labelText: 'Téléphone du destinataire',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            dropdownIconPosition: IconPosition.trailing,
            onChanged: (phone) =>
                notifier.update((d) => d.copyWith(recipientPhone: phone.completeNumber)),
          ),
        ],
      ),
    );
  }
}
