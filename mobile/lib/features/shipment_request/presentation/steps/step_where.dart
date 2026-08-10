import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers/shipment_providers.dart';

/// Etape "Ou" : adresses de collecte et de destination. Les coordonnees
/// sont pre-remplies automatiquement par geocodage (package geocoding,
/// geocodeur natif Android/iOS - gratuit, sans cle API) des que l'usager
/// quitte le champ adresse ; restent modifiables manuellement en secours
/// si le geocodeur echoue ou trouve une adresse imprecise.
class StepWhere extends ConsumerStatefulWidget {
  const StepWhere({super.key});

  @override
  ConsumerState<StepWhere> createState() => _StepWhereState();
}

class _StepWhereState extends ConsumerState<StepWhere> {
  late final TextEditingController _pickupAddressController;
  late final TextEditingController _pickupLatController;
  late final TextEditingController _pickupLngController;
  late final TextEditingController _destinationAddressController;
  late final TextEditingController _destinationLatController;
  late final TextEditingController _destinationLngController;
  late final FocusNode _pickupFocusNode;
  late final FocusNode _destinationFocusNode;

  bool _geocodingPickup = false;
  bool _geocodingDestination = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(shipmentDraftProvider);
    _pickupAddressController = TextEditingController(text: draft.pickupAddress);
    _pickupLatController = TextEditingController(
      text: draft.pickupLat?.toString(),
    );
    _pickupLngController = TextEditingController(
      text: draft.pickupLng?.toString(),
    );
    _destinationAddressController = TextEditingController(
      text: draft.destinationAddress,
    );
    _destinationLatController = TextEditingController(
      text: draft.destinationLat?.toString(),
    );
    _destinationLngController = TextEditingController(
      text: draft.destinationLng?.toString(),
    );

    _pickupFocusNode = FocusNode()
      ..addListener(() {
        if (!_pickupFocusNode.hasFocus) {
          _geocode(address: _pickupAddressController.text, isPickup: true);
        }
      });
    _destinationFocusNode = FocusNode()
      ..addListener(() {
        if (!_destinationFocusNode.hasFocus) {
          _geocode(
            address: _destinationAddressController.text,
            isPickup: false,
          );
        }
      });
  }

  @override
  void dispose() {
    _pickupAddressController.dispose();
    _pickupLatController.dispose();
    _pickupLngController.dispose();
    _destinationAddressController.dispose();
    _destinationLatController.dispose();
    _destinationLngController.dispose();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _geocode({
    required String address,
    required bool isPickup,
  }) async {
    if (address.trim().length < 3) return;

    setState(() {
      if (isPickup) {
        _geocodingPickup = true;
      } else {
        _geocodingDestination = true;
      }
    });

    final notifier = ref.read(shipmentDraftProvider.notifier);
    try {
      // Le geocodeur natif fonctionne mieux avec un contexte pays -
      // on suffixe "Cameroun" par defaut si l'usager ne l'a pas precise,
      // la zone CEMAC etant le perimetre principal de l'app.
      final query = address.toLowerCase().contains('cameroun')
          ? address
          : '$address, Cameroun';
      final results = await locationFromAddress(query);
      if (results.isEmpty || !mounted) return;

      final location = results.first;
      if (isPickup) {
        _pickupLatController.text = location.latitude.toStringAsFixed(6);
        _pickupLngController.text = location.longitude.toStringAsFixed(6);
        notifier.update(
          (d) => d.copyWith(
            pickupLat: location.latitude,
            pickupLng: location.longitude,
          ),
        );
      } else {
        _destinationLatController.text = location.latitude.toStringAsFixed(6);
        _destinationLngController.text = location.longitude.toStringAsFixed(6);
        notifier.update(
          (d) => d.copyWith(
            destinationLat: location.latitude,
            destinationLng: location.longitude,
          ),
        );
      }
    } catch (_) {
      // Geocodeur indisponible ou adresse introuvable - on laisse
      // simplement les champs lat/lng vides pour saisie manuelle,
      // pas d'erreur bloquante affichee (l'usager peut toujours saisir
      // les coordonnees a la main, cf. validators existants ci-dessous).
    } finally {
      if (mounted) {
        setState(() {
          if (isPickup) {
            _geocodingPickup = false;
          } else {
            _geocodingDestination = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(shipmentDraftProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Collecte', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pickupAddressController,
            focusNode: _pickupFocusNode,
            decoration: InputDecoration(
              labelText: 'Adresse de collecte',
              prefixIcon: const Icon(Icons.trip_origin),
              suffixIcon: _geocodingPickup
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            maxLength: 255,
            onChanged: (value) =>
                notifier.update((d) => d.copyWith(pickupAddress: value)),
            onEditingComplete: () => FocusScope.of(context).unfocus(),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pickupLatController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
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
                  controller: _pickupLngController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
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
            controller: _destinationAddressController,
            focusNode: _destinationFocusNode,
            decoration: InputDecoration(
              labelText: 'Adresse de destination',
              prefixIcon: const Icon(Icons.flag_outlined),
              suffixIcon: _geocodingDestination
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            maxLength: 255,
            onChanged: (value) =>
                notifier.update((d) => d.copyWith(destinationAddress: value)),
            onEditingComplete: () => FocusScope.of(context).unfocus(),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _destinationLatController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed >= -90 && parsed <= 90) {
                      notifier.update(
                        (d) => d.copyWith(destinationLat: parsed),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _destinationLngController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    if (parsed != null && parsed <= 180 && parsed >= -180) {
                      notifier.update(
                        (d) => d.copyWith(destinationLng: parsed),
                      );
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
