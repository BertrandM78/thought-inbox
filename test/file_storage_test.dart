import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:thought_inbox/models/thought.dart';
import 'package:thought_inbox/storage/thought_storage.dart';

void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('thought_inbox_test');
    file = File('${dir.path}/nested/thoughts.json');
  });

  tearDown(() => dir.delete(recursive: true));

  final thoughts = [
    Thought(id: 'a', text: 'Première', createdAt: DateTime.utc(2026, 10, 20)),
    Thought(
      id: 'b',
      text: 'Deuxième\nsur deux lignes',
      createdAt: DateTime.utc(2026, 10, 21),
      archived: true,
    ),
  ];

  test('retourne une liste vide sans fichier existant', () async {
    expect(await FileThoughtStorage(file).load(), isEmpty);
    expect(file.existsSync(), isFalse);
  });

  test('relit ce qui a été enregistré, y compris l’état archivé', () async {
    await FileThoughtStorage(file).save(thoughts);

    final reloaded = await FileThoughtStorage(file).load();

    expect(reloaded, thoughts);
    expect(File('${file.path}.tmp').existsSync(), isFalse);
  });

  test('migre les données de l’ancien chemin sans les altérer', () async {
    final legacyFile = File('${dir.path}/old/thoughts.json');
    final storage = FileThoughtStorage(file, legacyFile: legacyFile);
    await FileThoughtStorage(legacyFile).save(thoughts);

    final reloaded = await storage.load();

    expect(reloaded, thoughts);
    expect(await FileThoughtStorage(file).load(), thoughts);
    expect(await legacyFile.readAsString(), contains('"version":1'));
  });

  test('signale un échec de migration sans modifier la source', () async {
    final legacyFile = File('${dir.path}/old/thoughts.json');
    await FileThoughtStorage(legacyFile).save(thoughts);
    final blockedDirectory = File('${dir.path}/blocked');
    await blockedDirectory.writeAsString('not a directory');
    final blockedFile = File('${blockedDirectory.path}/thoughts.json');

    await expectLater(
      FileThoughtStorage(blockedFile, legacyFile: legacyFile).load(),
      throwsA(isA<StorageReadException>()),
    );
    expect(await FileThoughtStorage(legacyFile).load(), thoughts);
  });

  test('signale un fichier illisible sans le modifier', () async {
    await file.parent.create(recursive: true);
    await file.writeAsString('{ pas du json');

    await expectLater(
      FileThoughtStorage(file).load(),
      throwsA(isA<StorageReadException>()),
    );
    expect(await file.readAsString(), '{ pas du json');
  });

  test('signale un format inconnu ou une pensée invalide', () async {
    await file.parent.create(recursive: true);
    for (final content in [
      '[]',
      '{"version": 99, "thoughts": []}',
      '{"version": 1, "thoughts": [{"id": "a"}]}',
    ]) {
      await file.writeAsString(content);
      await expectLater(
        FileThoughtStorage(file).load(),
        throwsA(isA<StorageReadException>()),
        reason: content,
      );
    }
  });

  test('signale un échec d’écriture, garde le fichier précédent', () async {
    final storage = FileThoughtStorage(file);
    await storage.save(thoughts);
    // Un dossier à la place du fichier temporaire fait échouer l’écriture.
    await Directory('${file.path}.tmp').create();

    await expectLater(
      storage.save(const []),
      throwsA(isA<StorageWriteException>()),
    );
    expect(await storage.load(), thoughts);
  });
}
