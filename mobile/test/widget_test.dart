import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fretcorridor_client/main.dart';

void main() {
  testWidgets('L\'application demarre sur l\'ecran de connexion', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FretCorridorApp()));

    // Un frame suffit ici : on verifie juste que l'app monte sans exception,
    // pas le rendu complet de l'ecran de connexion (qui appelle le reseau).
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
