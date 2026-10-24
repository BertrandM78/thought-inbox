import 'package:flutter_test/flutter_test.dart';
import 'package:thought_inbox/models/thought.dart';
import 'package:thought_inbox/state/thought_inbox_controller.dart';
import 'package:thought_inbox/storage/thought_storage.dart';

import 'support/memory_storage.dart';

void main() {
  late MemoryThoughtStorage storage;

  ThoughtInboxController newController() => ThoughtInboxController(
    storage: storage,
    clock: steppingClock(),
    idGenerator: sequentialIds(),
  );

  setUp(() => storage = MemoryThoughtStorage());

  test('commence en chargement puis devient prêt, inbox vide', () async {
    final controller = newController();
    expect(controller.status, LoadStatus.loading);
    expect(controller.canMutate, isFalse);

    await controller.load();

    expect(controller.status, LoadStatus.ready);
    expect(controller.inbox, isEmpty);
    expect(controller.archived, isEmpty);
  });

  test('retire les espaces et enregistre id, texte, date et état', () async {
    final controller = newController();
    await controller.load();

    final result = await controller.add('  Explorer cette idée samedi \n');

    expect(result, AddResult.added);

    expect(storage.saved, [
      Thought(
        id: 'id-1',
        text: 'Explorer cette idée samedi',
        createdAt: DateTime.utc(2026, 10, 20, 9),
      ),
    ]);
  });

  test('refuse une entrée vide ou blanche sans écrire', () async {
    final controller = newController();
    await controller.load();

    for (final text in ['', '   ', '\n\t ']) {
      expect(await controller.add(text), AddResult.empty);
    }
    expect(controller.inbox, isEmpty);
    expect(storage.saveCount, 0);
  });

  test('affiche la pensée la plus récente en premier', () async {
    final controller = newController();
    await controller.load();

    await controller.add('Première');
    await controller.add('Deuxième');

    expect(controller.inbox.map((t) => t.text), ['Deuxième', 'Première']);
  });

  test('trie aussi les données relues dans le désordre', () async {
    storage = MemoryThoughtStorage([
      Thought(id: 'old', text: 'Ancienne', createdAt: DateTime.utc(2026, 1, 1)),
      Thought(id: 'new', text: 'Récente', createdAt: DateTime.utc(2026, 9, 1)),
    ]);
    final controller = newController();
    await controller.load();

    expect(controller.inbox.map((t) => t.id), ['new', 'old']);
  });

  test('archive puis restaure une pensée', () async {
    final controller = newController();
    await controller.load();
    await controller.add('Une');
    await controller.add('Deux');

    await controller.archive('id-1');
    expect(controller.inbox.map((t) => t.text), ['Deux']);
    expect(controller.archived.map((t) => t.text), ['Une']);
    expect(storage.saved.firstWhere((t) => t.id == 'id-1').archived, isTrue);

    await controller.restore('id-1');
    expect(controller.inbox.map((t) => t.text), ['Deux', 'Une']);
    expect(controller.archived, isEmpty);
    expect(storage.saved.every((t) => !t.archived), isTrue);
  });

  test('un nouveau contrôleur retrouve les pensées et leur état', () async {
    final first = newController();
    await first.load();
    await first.add('Gardée');
    await first.add('Archivée');
    await first.archive('id-2');

    final relaunched = newController();
    await relaunched.load();

    expect(relaunched.inbox.map((t) => t.text), ['Gardée']);
    expect(relaunched.archived.map((t) => t.text), ['Archivée']);
  });

  test('un échec d’écriture laisse l’état inchangé et remonte', () async {
    final controller = newController();
    await controller.load();
    await controller.add('Existante');
    storage.failSave = true;

    await expectLater(
      controller.add('Nouvelle'),
      throwsA(isA<StorageWriteException>()),
    );
    await expectLater(
      controller.archive('id-1'),
      throwsA(isA<StorageWriteException>()),
    );

    expect(controller.inbox.map((t) => t.text), ['Existante']);
    expect(controller.archived, isEmpty);
    expect(controller.isSaving, isFalse);

    storage.failSave = false;
    await controller.add('Après reprise');
    expect(controller.inbox.map((t) => t.text), ['Après reprise', 'Existante']);
  });

  test('un échec de lecture bloque les mutations sans rien écrire', () async {
    storage.failLoad = true;
    final controller = newController();
    await controller.load();

    expect(controller.status, LoadStatus.failed);
    expect(controller.loadError, isA<StorageReadException>());
    await expectLater(controller.add('Texte'), throwsStateError);
    expect(storage.saveCount, 0);

    storage.failLoad = false;
    await controller.load();
    expect(controller.status, LoadStatus.ready);
  });

  test('refuse les mutations avant la fin du chargement', () async {
    final controller = newController();

    await expectLater(controller.add('Trop tôt'), throwsStateError);
    expect(storage.saveCount, 0);
  });

  test('supprime une pensée du stockage, distinct du traitement', () async {
    final controller = newController();
    await controller.load();
    await controller.add('Gardée');
    await controller.add('Jetée');

    final removed = await controller.delete('id-2');

    expect(removed?.text, 'Jetée');
    expect(controller.inbox.map((t) => t.text), ['Gardée']);
    expect(controller.archived, isEmpty);
    expect(storage.saved.map((t) => t.id), ['id-1']);
  });

  test('annuler une suppression restaure la pensée à l’identique', () async {
    final original = Thought(
      id: 'ancienne',
      text: 'Ligne 1\nLigne 2',
      createdAt: DateTime.utc(2025, 3, 4, 5, 6, 7, 8),
    );
    storage = MemoryThoughtStorage([
      original,
      Thought(id: 'récente', text: 'Récente', createdAt: DateTime.utc(2026)),
    ]);
    final controller = newController();
    await controller.load();

    final removed = await controller.delete('ancienne');
    await controller.undoDelete(removed!);

    expect(controller.inbox.map((t) => t.id), ['récente', 'ancienne']);
    expect(storage.saved.firstWhere((t) => t.id == 'ancienne'), original);
    final relaunched = newController();
    await relaunched.load();
    expect(relaunched.inbox.last, original);
  });

  test('annuler conserve le statut traité et ne duplique pas', () async {
    final done = Thought(
      id: 'faite',
      text: 'Traitée',
      createdAt: DateTime.utc(2026),
      archived: true,
    );
    storage = MemoryThoughtStorage([done]);
    final controller = newController();
    await controller.load();

    await controller.undoDelete(done);
    expect(storage.saved, [done]);

    final removed = await controller.delete('faite');
    await controller.undoDelete(removed!);
    expect(storage.saved, [done]);
    expect(controller.inbox, isEmpty);
  });

  test('un échec de suppression ou d’annulation ne perd rien', () async {
    final controller = newController();
    await controller.load();
    await controller.add('Fragile');
    storage.failSave = true;

    await expectLater(
      controller.delete('id-1'),
      throwsA(isA<StorageWriteException>()),
    );
    expect(controller.inbox.map((t) => t.text), ['Fragile']);

    storage.failSave = false;
    final removed = await controller.delete('id-1');
    storage.failSave = true;
    await expectLater(
      controller.undoDelete(removed!),
      throwsA(isA<StorageWriteException>()),
    );
    expect(controller.inbox, isEmpty);

    storage.failSave = false;
    await controller.undoDelete(removed);
    expect(storage.saved, [removed]);
  });

  test('des suppressions successives restent indépendantes', () async {
    final controller = newController();
    await controller.load();
    await controller.add('A');
    await controller.add('B');
    await controller.add('C');

    final a = await controller.delete('id-1');
    await controller.delete('id-2');
    await controller.undoDelete(a!);

    expect(controller.inbox.map((t) => t.text), ['C', 'A']);
    expect(storage.saved.map((t) => t.id).toSet(), {'id-1', 'id-3'});
  });

  test('des mutations simultanées sont toutes conservées', () async {
    final controller = newController();
    await controller.load();

    await Future.wait([
      controller.add('A'),
      controller.add('B'),
      controller.add('C'),
    ]);

    expect(storage.saved.map((t) => t.text), ['A', 'B', 'C']);
  });
}
