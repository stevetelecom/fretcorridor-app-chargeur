import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';

/// Toggle visuel FR | EN (pas un Switch binaire classique, plus lisible
/// pour un choix de langue). Affiche la locale effective : celle choisie
/// manuellement si presente, sinon la locale systeme actuelle - pour que
/// l'etat visuel corresponde toujours a ce que l'utilisateur voit reellement
/// a l'ecran, meme avant tout choix explicite.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chosenLocale = ref.watch(localeProvider);
    final effectiveCode = chosenLocale?.languageCode ?? Localizations.localeOf(context).languageCode;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _option(context, ref, label: 'FR', code: 'fr', effectiveCode: effectiveCode),
          _option(context, ref, label: 'EN', code: 'en', effectiveCode: effectiveCode),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required String code,
    required String effectiveCode,
  }) {
    final isSelected = effectiveCode == code;
    return GestureDetector(
      onTap: () => setAppLocale(ref, Locale(code)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
