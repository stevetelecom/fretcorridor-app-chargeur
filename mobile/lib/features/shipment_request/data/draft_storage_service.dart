import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/shipment_request_draft.dart';

/// Persiste le brouillon en JSON brut dans une Hive box (pas d'adapter
/// genere : le brouillon est petit et change souvent, un simple
/// encode/decode JSON evite la complexite de build_runner pour ce cas).
/// Repond a UC-MKT-01 E4 (coupure reseau/appli fermee en cours de saisie).
class DraftStorageService {
  static const _boxName = 'shipment_draft_box';
  static const _draftKey = 'current_draft';

  Future<Box> _openBox() => Hive.openBox(_boxName);

  Future<void> save(ShipmentRequestDraft draft) async {
    final box = await _openBox();
    await box.put(_draftKey, jsonEncode(draft.toJson()));
  }

  Future<ShipmentRequestDraft?> load() async {
    final box = await _openBox();
    final raw = box.get(_draftKey);
    if (raw == null) return null;
    return ShipmentRequestDraft.fromJson(jsonDecode(raw as String));
  }

  Future<void> clear() async {
    final box = await _openBox();
    await box.delete(_draftKey);
  }
}
