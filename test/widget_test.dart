import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thought_inbox/app.dart';
import 'package:thought_inbox/models/thought.dart';
import 'package:thought_inbox/state/thought_inbox_controller.dart';

import 'support/memory_storage.dart';

void main() {
  late MemoryThoughtStorage storage;

  setUp(() => storage = MemoryThoughtStorage());

  Future<ThoughtInboxController> launch(WidgetTester tester) async {
    final controller = ThoughtInboxController(
      storage: storage,
      clock: steppingClock(DateTime(2026, 10, 20, 14, 5)),
      idGenerator: sequentialIds(),
    );
    await tester.pumpWidget(ThoughtInboxApp(controller: controller));
    await controller.load();
    await tester.pumpAndSettle();
    return controller;
  }

  Future<void> deposit(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.text('Déposer'));
    await tester.pumpAndSettle();
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('une nouvelle installation montre une inbox vide', (
    tester,
  ) async {
    await launch(tester);

    expect(find.text('Inbox'), findsWidgets);
    expect(find.textContaining('Votre inbox est vide.'), findsOneWidget);
    expect(find.text('Nouvelle pensée'), findsOneWidget);
  });

  testWidgets('dépose une pensée et vide le champ', (tester) async {
    await launch(tester);

    await deposit(tester, '  Explorer cette idée samedi  ');

    expect(find.text('Explorer cette idée samedi'), findsOneWidget);
    expect(find.text('20 oct. 2026, 14:05'), findsOneWidget);
    expect(find.textContaining('Votre inbox est vide.'), findsNothing);
    expect(fieldText(tester), isEmpty);
    expect(storage.saved, hasLength(1));
  });

  testWidgets('une entrée blanche n’ajoute rien et explique pourquoi', (
    tester,
  ) async {
    await launch(tester);

    await deposit(tester, '   \n  ');

    expect(
      find.text('Écrivez quelque chose avant de déposer.'),
      findsOneWidget,
    );
    expect(find.textContaining('Votre inbox est vide.'), findsOneWidget);
    expect(storage.saveCount, 0);
  });

  testWidgets('affiche deux pensées de la plus récente à la plus ancienne', (
    tester,
  ) async {
    await launch(tester);

    await deposit(tester, 'Première');
    await deposit(tester, 'Deuxième');

    final first = tester.getTopLeft(find.text('Deuxième')).dy;
    final second = tester.getTopLeft(find.text('Première')).dy;
    expect(first, lessThan(second));
  });

  testWidgets('archive puis restaure une pensée', (tester) async {
    await launch(tester);
    await deposit(tester, 'À ranger');

    await tester.tap(find.text('Archiver'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Votre inbox est vide.'), findsOneWidget);

    await tester.tap(find.text('Archives'));
    await tester.pumpAndSettle();
    expect(find.text('À ranger'), findsOneWidget);

    await tester.tap(find.text('Restaurer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aucune pensée archivée.'), findsOneWidget);

    await tester.tap(find.text('Inbox'));
    await tester.pumpAndSettle();
    expect(find.text('À ranger'), findsOneWidget);
  });

  testWidgets('un relancement retrouve les pensées et leur état', (
    tester,
  ) async {
    storage = MemoryThoughtStorage([
      Thought(id: 'a', text: 'Active', createdAt: DateTime(2026, 10, 19)),
      Thought(
        id: 'b',
        text: 'Rangée',
        createdAt: DateTime(2026, 10, 18),
        archived: true,
      ),
    ]);
    await launch(tester);

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Rangée'), findsNothing);

    await tester.tap(find.text('Archives'));
    await tester.pumpAndSettle();
    expect(find.text('Rangée'), findsOneWidget);
  });

  testWidgets('un échec d’écriture conserve la saisie et l’annonce', (
    tester,
  ) async {
    await launch(tester);
    storage.failSave = true;

    await deposit(tester, 'Ne pas perdre');

    expect(
      find.text('La pensée n’a pas été enregistrée. Votre texte est conservé.'),
      findsOneWidget,
    );
    expect(fieldText(tester), 'Ne pas perdre');
    expect(find.textContaining('Votre inbox est vide.'), findsOneWidget);
  });

  testWidgets('un échec d’archivage est signalé', (tester) async {
    await launch(tester);
    await deposit(tester, 'Résistante');
    storage.failSave = true;

    await tester.tap(find.text('Archiver'));
    await tester.pumpAndSettle();

    expect(
      find.text('La pensée n’a pas pu être archivée. Réessayez.'),
      findsOneWidget,
    );
    expect(find.text('Résistante'), findsOneWidget);
  });

  testWidgets('un échec de chargement bloque le dépôt et permet de réessayer', (
    tester,
  ) async {
    storage.failLoad = true;
    await launch(tester);

    expect(find.textContaining('n’ont pas pu être chargées'), findsWidgets);
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Déposer'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(button.onPressed, isNull);

    storage.failLoad = false;
    await tester.tap(find.text('Réessayer').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Votre inbox est vide.'), findsOneWidget);
  });
}
