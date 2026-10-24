import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thought_inbox/app.dart';
import 'package:thought_inbox/models/thought.dart';
import 'package:thought_inbox/state/thought_inbox_controller.dart';
import 'package:thought_inbox/ui/theme/app_colors.dart' as colors;

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

  Finder depositButton() => find.ancestor(
    of: find.text('Déposer'),
    matching: find.bySubtype<ButtonStyleButton>(),
  );

  bool depositEnabled(WidgetTester tester) =>
      tester.widget<ButtonStyleButton>(depositButton()).onPressed != null;

  Future<void> deposit(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
    await tester.tap(find.text('Déposer'));
    await tester.pumpAndSettle();
  }

  Future<void> openInbox(WidgetTester tester) async {
    await tester.tap(find.byIcon(CupertinoIcons.tray));
    await tester.pumpAndSettle();
  }

  Future<void> backToCapture(WidgetTester tester) async {
    await tester.tap(find.text('Capturer'));
    await tester.pumpAndSettle();
  }

  Future<void> openMenuAndChoose(WidgetTester tester, String action) async {
    await tester.tap(find.byTooltip('Actions pour cette pensée').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
  }

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testWidgets('une installation neuve ouvre Capture, Déposer inactif', (
    tester,
  ) async {
    await launch(tester);

    expect(find.text('posé.'), findsOneWidget);
    expect(find.text('CAPTUREZ MAINTENANT'), findsOneWidget);
    expect(find.text('Qu’avez-vous en tête ?'), findsOneWidget);
    expect(find.text('Pas de titre, pas de tri.'), findsOneWidget);
    expect(find.text('Traitez plus tard, l’esprit libre.'), findsOneWidget);
    expect(depositEnabled(tester), isFalse);
  });

  testWidgets('un texte blanc laisse Déposer inactif, sans écriture', (
    tester,
  ) async {
    await launch(tester);

    await tester.enterText(find.byType(TextField), '   \n  ');
    await tester.pump();
    expect(depositEnabled(tester), isFalse);
    await tester.tap(find.text('Déposer'));
    await tester.pumpAndSettle();

    expect(storage.saveCount, 0);
  });

  testWidgets('déposer confirme après sauvegarde et met à jour le compteur', (
    tester,
  ) async {
    await launch(tester);

    await tester.enterText(find.byType(TextField), '  Explorer\ncette idée  ');
    await tester.pump();
    expect(find.text('23 caractères'), findsOneWidget);
    await tester.tap(find.text('Déposer'));
    await tester.pumpAndSettle();

    expect(fieldText(tester), isEmpty);
    expect(find.text('Déposé. Vous y reviendrez.'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(storage.saved.single.text, 'Explorer\ncette idée');

    await tester.enterText(find.byType(TextField), 'S');
    await tester.pump();
    expect(find.text('Déposé. Vous y reviendrez.'), findsNothing);
    expect(find.text('1 caractère'), findsOneWidget);
  });

  testWidgets('des appuis rapides n’enregistrent qu’une fois', (tester) async {
    await launch(tester);
    storage.saveGate = Completer();

    await tester.enterText(find.byType(TextField), 'Une seule fois');
    await tester.pump();
    await tester.tap(find.text('Déposer'));
    await tester.tap(find.text('Déposer'), warnIfMissed: false);
    await tester.pump();
    expect(depositEnabled(tester), isFalse);
    expect(find.text('Déposé. Vous y reviendrez.'), findsNothing);
    expect(fieldText(tester), 'Une seule fois');

    storage.saveGate!.complete();
    await tester.pumpAndSettle();

    expect(storage.saveCount, 1);
    expect(storage.saved, hasLength(1));
  });

  testWidgets('un échec d’écriture conserve la saisie sans faux succès', (
    tester,
  ) async {
    await launch(tester);
    storage.failSave = true;

    await deposit(tester, 'Ne pas perdre');

    expect(
      find.text('La pensée n’a pas été enregistrée. Votre texte est conservé.'),
      findsOneWidget,
    );
    expect(find.text('Déposé. Vous y reviendrez.'), findsNothing);
    expect(fieldText(tester), 'Ne pas perdre');
    expect(depositEnabled(tester), isTrue);
  });

  testWidgets('À traiter liste de la plus récente à la plus ancienne', (
    tester,
  ) async {
    await launch(tester);

    await deposit(tester, 'Première');
    await deposit(tester, 'Deuxième');
    await openInbox(tester);

    expect(find.text('2 en attente'), findsOneWidget);
    final first = tester.getTopLeft(find.text('Deuxième')).dy;
    final second = tester.getTopLeft(find.text('Première')).dy;
    expect(first, lessThan(second));
  });

  testWidgets('aucune suggestion ni accès Archives', (tester) async {
    storage = MemoryThoughtStorage([
      Thought(
        id: 'a',
        text: 'Appeler Michel demain pour le déménagement',
        createdAt: DateTime(2026, 10, 20, 13),
      ),
      Thought(
        id: 'b',
        text: 'Ancienne traitée',
        createdAt: DateTime(2026, 10, 1),
        archived: true,
      ),
    ]);
    await launch(tester);
    await openInbox(tester);

    expect(find.textContaining('Téléphone'), findsNothing);
    expect(find.textContaining('Archive'), findsNothing);
    expect(find.text('Ancienne traitée'), findsNothing);
    await tester.tap(find.byTooltip('Actions pour cette pensée'));
    await tester.pumpAndSettle();
    expect(find.text('Marquer traitée'), findsOneWidget);
    expect(find.text('Supprimer'), findsOneWidget);
    expect(find.textContaining('Archive'), findsNothing);
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();
    expect(storage.saveCount, 0);
  });

  testWidgets('marquer traitée retire la carte et conserve la pensée', (
    tester,
  ) async {
    storage = MemoryThoughtStorage([
      Thought(
        id: 'old',
        text: 'Déjà traitée',
        createdAt: DateTime(2026, 9, 1),
        archived: true,
      ),
    ]);
    await launch(tester);
    await deposit(tester, 'À ranger');
    await openInbox(tester);

    await tester.tap(find.byTooltip('Marquer traitée'));
    await tester.pumpAndSettle();

    expect(find.text('À ranger'), findsNothing);
    expect(find.text('Esprit clair.'), findsOneWidget);
    expect(find.text('0 en attente'), findsOneWidget);
    expect(storage.saved.map((t) => (t.id, t.archived)), [
      ('old', true),
      ('id-1', true),
    ]);
  });

  testWidgets('marquer traitée depuis le menu ; un échec garde la carte', (
    tester,
  ) async {
    await launch(tester);
    await deposit(tester, 'Résistante');
    await openInbox(tester);
    storage.failSave = true;

    await openMenuAndChoose(tester, 'Marquer traitée');

    expect(
      find.text('La pensée n’a pas pu être marquée traitée. Réessayez.'),
      findsOneWidget,
    );
    expect(find.text('Résistante'), findsOneWidget);

    storage.failSave = false;
    await openMenuAndChoose(tester, 'Marquer traitée');
    expect(find.text('Résistante'), findsNothing);
    expect(storage.saved.single.archived, isTrue);
  });

  testWidgets('supprimer puis annuler restaure la pensée à l’identique', (
    tester,
  ) async {
    final original = Thought(
      id: 'x',
      text: 'À garder finalement',
      createdAt: DateTime.utc(2026, 10, 19, 8, 30, 12, 345),
    );
    storage = MemoryThoughtStorage([original]);
    await launch(tester);
    await openInbox(tester);

    await openMenuAndChoose(tester, 'Supprimer');

    expect(find.text('À garder finalement'), findsNothing);
    expect(storage.saved, isEmpty);
    expect(find.text('Pensée supprimée.'), findsOneWidget);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('À garder finalement'), findsOneWidget);
    expect(storage.saved, [original]);
    expect(find.text('Annuler'), findsNothing);
  });

  testWidgets('Annuler expire après cinq secondes ; la suppression reste', (
    tester,
  ) async {
    await launch(tester);
    await deposit(tester, 'Éphémère');
    await openInbox(tester);

    await openMenuAndChoose(tester, 'Supprimer');
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Annuler'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1, milliseconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Annuler'), findsNothing);
    expect(storage.saved, isEmpty);
    expect(find.text('Esprit clair.'), findsOneWidget);
  });

  testWidgets('une nouvelle suppression clôt l’annulation précédente', (
    tester,
  ) async {
    await launch(tester);
    await deposit(tester, 'Première');
    await deposit(tester, 'Seconde');
    await openInbox(tester);

    await openMenuAndChoose(tester, 'Supprimer');
    await openMenuAndChoose(tester, 'Supprimer');
    expect(find.text('Annuler'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(storage.saved.map((t) => t.text), ['Première']);
    expect(find.text('Première'), findsOneWidget);
    expect(find.text('Seconde'), findsNothing);
  });

  testWidgets('un échec de suppression garde la carte et l’annonce', (
    tester,
  ) async {
    await launch(tester);
    await deposit(tester, 'Tenace');
    await openInbox(tester);
    storage.failSave = true;

    await openMenuAndChoose(tester, 'Supprimer');

    expect(
      find.text('La pensée n’a pas pu être supprimée. Réessayez.'),
      findsOneWidget,
    );
    expect(find.text('Tenace'), findsOneWidget);
    expect(find.text('Annuler'), findsNothing);
    expect(storage.saved, hasLength(1));
  });

  testWidgets('un échec d’annulation est signalé et peut être repris', (
    tester,
  ) async {
    await launch(tester);
    await deposit(tester, 'Revenante');
    final saved = storage.saved.single;
    await openInbox(tester);

    await openMenuAndChoose(tester, 'Supprimer');
    storage.failSave = true;
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('La pensée n’a pas pu être restaurée.'), findsOneWidget);
    expect(find.text('Revenante'), findsNothing);
    expect(storage.saved, isEmpty);

    storage.failSave = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Revenante'), findsOneWidget);
    expect(storage.saved, [saved]);
  });

  testWidgets('le brouillon survit aux allers-retours entre les écrans', (
    tester,
  ) async {
    await launch(tester);
    await tester.enterText(find.byType(TextField), 'En cours');
    await tester.pump();

    await openInbox(tester);
    expect(find.text('À traiter'), findsOneWidget);
    expect(find.text('Esprit clair.'), findsOneWidget);
    await backToCapture(tester);
    expect(fieldText(tester), 'En cours');

    await openInbox(tester);
    await tester.tap(find.text('Capturer une pensée'));
    await tester.pumpAndSettle();
    expect(find.text('CAPTUREZ MAINTENANT'), findsOneWidget);
    expect(fieldText(tester), 'En cours');
  });

  testWidgets('reste en thème clair quand l’iPhone est en mode sombre', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await launch(tester);

    final context = tester.element(find.text('CAPTUREZ MAINTENANT'));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(CupertinoTheme.of(context).brightness, Brightness.light);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor ??
          Theme.of(context).scaffoldBackgroundColor,
      colors.background,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).keyboardAppearance,
      Brightness.light,
    );
  });

  testWidgets('un échec de chargement bloque le dépôt et permet de réessayer', (
    tester,
  ) async {
    storage.failLoad = true;
    await launch(tester);

    expect(find.textContaining('n’ont pas pu être chargées'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Texte');
    await tester.pump();
    expect(depositEnabled(tester), isFalse);

    storage.failLoad = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('n’ont pas pu être chargées'), findsNothing);
    expect(depositEnabled(tester), isTrue);
    expect(fieldText(tester), 'Texte');
  });

  testWidgets('petit écran, texte ×2 et pensée longue sans débordement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    storage = MemoryThoughtStorage([
      Thought(
        id: 'long',
        text: List.filled(60, 'Une pensée très longue').join(' '),
        createdAt: DateTime(2026, 10, 20, 9),
      ),
    ]);
    await launch(tester);
    await tester.enterText(find.byType(TextField), 'Brouillon');
    await tester.pump();
    expect(tester.takeException(), isNull);

    await openInbox(tester);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byTooltip('Actions pour cette pensée'),
      100,
    );
    await openMenuAndChoose(tester, 'Supprimer');
    expect(tester.takeException(), isNull);
    expect(find.text('Annuler'), findsOneWidget);
  });

  testWidgets('les actions ont des libellés VoiceOver explicites', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await launch(tester);
    await deposit(tester, 'Lisible');

    expect(find.bySemanticsLabel('À traiter, 1 en attente'), findsOneWidget);
    await openInbox(tester);
    expect(find.bySemanticsLabel('Capturer'), findsOneWidget);
    expect(find.bySemanticsLabel('Marquer traitée'), findsOneWidget);
    expect(find.bySemanticsLabel('Actions pour cette pensée'), findsOneWidget);
    semantics.dispose();
  });
}
