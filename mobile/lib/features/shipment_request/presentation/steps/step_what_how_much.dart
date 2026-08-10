import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/shipment_providers.dart';
import '../catalog_icon.dart';

/// Etape "Quoi/Combien/Nature" : selection visuelle dans le catalogue
/// (grille de cartes, pas un menu deroulant - plan §4 "selection visuelle du
/// catalogue"), quantite, et case fragile.
class StepWhatHowMuch extends ConsumerWidget {
  const StepWhatHowMuch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(catalogProvider);
    final draft = ref.watch(shipmentDraftProvider);
    final notifier = ref.read(shipmentDraftProvider.notifier);

    return catalogAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.primary, size: 40),
              const SizedBox(height: 12),
              const Text('Impossible de charger le catalogue.'),
              TextButton(
                onPressed: () => ref.invalidate(catalogProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
      data: (catalog) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Type de colis', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: catalog.length,
              itemBuilder: (context, index) {
                final item = catalog[index];
                final selected = draft.packageCatalogItemId == item.id;
                return _CatalogCard(
                  label: item.label,
                  icon: catalogIconFor(item.iconName),
                  selected: selected,
                  onTap: () => notifier.update((d) => d.copyWith(
                        packageCatalogItemId: item.id,
                        fragile: item.fragileByDefault,
                      )),
                );
              },
            ),
            const SizedBox(height: 24),
            Text('Quantité', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: draft.quantity > 1
                      ? () => notifier.update((d) => d.copyWith(quantity: d.quantity - 1))
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('${draft.quantity}', style: Theme.of(context).textTheme.headlineSmall),
                ),
                IconButton.filledTonal(
                  onPressed: draft.quantity < 500
                      ? () => notifier.update((d) => d.copyWith(quantity: d.quantity + 1))
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: draft.fragile,
              onChanged: (value) => notifier.update((d) => d.copyWith(fragile: value)),
              title: const Text('Marchandise fragile'),
              subtitle: const Text('Coché automatiquement pour certains types de colis'),
              secondary: const Icon(Icons.warning_amber_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Charte stricte FretCorridor (rouge/noir/blanc) : pas de gris
    // neutre - fond blanc, contour et icone en noir franc au repos, tout
    // bascule en rouge de marque a la selection (fond teinte, contour et
    // icone rouges, texte en gras pour renforcer l'etat actif).
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.black87,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: selected ? AppColors.primary : Colors.black87),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? AppColors.primary : Colors.black87,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
