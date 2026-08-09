/// Entree du catalogue reduit (~15 items, cf. backend V4). Correspond 1:1
/// au DTO PackageCatalogItemResponse - aucune transformation cote client.
class PackageCatalogItem {
  PackageCatalogItem({
    required this.id,
    required this.code,
    required this.label,
    required this.category,
    required this.defaultWeightKg,
    required this.defaultVolumeM3,
    required this.fragileByDefault,
    required this.iconName,
  });

  final String id;
  final String code;
  final String label;
  final String category;
  final double defaultWeightKg;
  final double defaultVolumeM3;
  final bool fragileByDefault;
  final String iconName;

  factory PackageCatalogItem.fromJson(Map<String, dynamic> json) => PackageCatalogItem(
        id: json['id'],
        code: json['code'],
        label: json['label'],
        category: json['category'],
        defaultWeightKg: (json['defaultWeightKg'] as num).toDouble(),
        defaultVolumeM3: (json['defaultVolumeM3'] as num).toDouble(),
        fragileByDefault: json['fragileByDefault'],
        iconName: json['iconName'],
      );
}
