import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Traduit le champ icon_name (venu du backend, seede en V4) vers une
/// IconData Material Symbols reelle - jamais d'emoji (regle du guide
/// ultime). Fallback sur une icone generique si un code inconnu arrive
/// (catalogue etendu cote backend sans mise a jour immediate du client).
IconData catalogIconFor(String iconName) {
  switch (iconName) {
    case 'inventory_2':
      return Symbols.inventory_2;
    case 'description':
      return Symbols.description;
    case 'pallet':
      return Symbols.pallet;
    case 'grain':
      return Symbols.grain;
    case 'construction':
      return Symbols.construction;
    case 'water_drop':
      return Symbols.water_drop;
    case 'liquor':
      return Symbols.liquor;
    case 'kitchen':
      return Symbols.kitchen;
    case 'tv':
      return Symbols.tv;
    case 'chair':
      return Symbols.chair;
    case 'bed':
      return Symbols.bed;
    case 'directions_bike':
      return Symbols.directions_bike;
    case 'two_wheeler':
      return Symbols.two_wheeler;
    case 'bolt':
      return Symbols.bolt;
    default:
      return Symbols.package_2;
  }
}
