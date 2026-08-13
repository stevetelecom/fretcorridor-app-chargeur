import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Langue choisie manuellement (FR/EN) via le toggle, persistee dans la
/// box Hive 'app_prefs' (meme box que l'onboarding - evite d'ouvrir une
/// box dediee pour une seule preference). null = pas de choix explicite,
/// Flutter suit alors la langue du systeme (MaterialApp.router avec
/// locale: null retombe sur supportedLocales / la locale de l'appareil).
const String localeBoxName = 'app_prefs';
const String localeHiveKey = 'locale_code';

final localeProvider = StateProvider<Locale?>((ref) {
  final box = Hive.box(localeBoxName);
  final saved = box.get(localeHiveKey) as String?;
  return saved == null ? null : Locale(saved);
});

/// Persiste ET met a jour le provider en un seul appel - a utiliser depuis
/// le toggle plutot que manipuler Hive directement dans chaque widget.
void setAppLocale(WidgetRef ref, Locale locale) {
  Hive.box(localeBoxName).put(localeHiveKey, locale.languageCode);
  ref.read(localeProvider.notifier).state = locale;
}
