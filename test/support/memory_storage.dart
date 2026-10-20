import 'package:thought_inbox/models/thought.dart';
import 'package:thought_inbox/storage/thought_storage.dart';

/// Stockage en mémoire, avec échecs simulables.
class MemoryThoughtStorage implements ThoughtStorage {
  MemoryThoughtStorage([List<Thought> initial = const []])
    : saved = List.of(initial);

  List<Thought> saved;
  bool failLoad = false;
  bool failSave = false;
  int saveCount = 0;

  @override
  Future<List<Thought>> load() async {
    if (failLoad) throw const StorageReadException('échec simulé');
    return List.of(saved);
  }

  @override
  Future<void> save(List<Thought> thoughts) async {
    if (failSave) throw const StorageWriteException('échec simulé');
    saveCount++;
    saved = List.of(thoughts);
  }
}

/// Horloge de test qui avance d’une minute à chaque appel.
DateTime Function() steppingClock([DateTime? start]) {
  var next = start ?? DateTime.utc(2026, 10, 20, 9);
  return () {
    final now = next;
    next = next.add(const Duration(minutes: 1));
    return now;
  };
}

/// Générateur d’identifiants déterministe.
String Function() sequentialIds() {
  var i = 0;
  return () => 'id-${++i}';
}
