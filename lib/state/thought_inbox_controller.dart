import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/thought.dart';
import '../storage/thought_storage.dart';

enum LoadStatus { loading, ready, failed }

/// Résultat d’un dépôt de pensée.
enum AddResult { added, empty }

/// État de l’inbox. Chaque mutation est enregistrée avant d’être appliquée :
/// en cas d’échec d’écriture, l’état affiché reste celui du stockage et
/// l’erreur est propagée à l’appelant.
class ThoughtInboxController extends ChangeNotifier {
  ThoughtInboxController({
    required this.storage,
    DateTime Function()? clock,
    String Function()? idGenerator,
  }) : _clock = clock ?? DateTime.now,
       _idGenerator = idGenerator ?? _randomId;

  final ThoughtStorage storage;
  final DateTime Function() _clock;
  final String Function() _idGenerator;

  LoadStatus _status = LoadStatus.loading;
  Object? _loadError;
  List<Thought> _thoughts = const [];
  Future<void> _pending = Future.value();
  bool _saving = false;

  LoadStatus get status => _status;
  Object? get loadError => _loadError;

  /// Vrai pendant l’enregistrement d’une modification.
  bool get isSaving => _saving;

  /// Les mutations ne sont possibles qu’après un chargement réussi.
  bool get canMutate => _status == LoadStatus.ready;

  List<Thought> get inbox => _sorted(_thoughts.where((t) => !t.archived));
  List<Thought> get archived => _sorted(_thoughts.where((t) => t.archived));

  /// Charge les pensées. En cas d’échec, rien n’est écrit : les données
  /// existantes restent intactes et [load] peut être relancé.
  Future<void> load() async {
    _status = LoadStatus.loading;
    _loadError = null;
    notifyListeners();
    try {
      _thoughts = List.unmodifiable(await storage.load());
      _status = LoadStatus.ready;
    } on Object catch (error) {
      _loadError = error;
      _status = LoadStatus.failed;
    }
    notifyListeners();
  }

  /// Dépose une pensée. Retourne [AddResult.empty] sans rien enregistrer si
  /// le texte est vide ou blanc. Lève [StorageWriteException] si l’écriture
  /// échoue.
  Future<AddResult> add(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return Future.value(AddResult.empty);
    return _mutate((thoughts) {
      final thought = Thought(
        id: _idGenerator(),
        text: text,
        createdAt: _clock(),
      );
      return [...thoughts, thought];
    }).then((_) => AddResult.added);
  }

  Future<void> archive(String id) => _setArchived(id, true);

  Future<void> restore(String id) => _setArchived(id, false);

  Future<void> _setArchived(String id, bool value) => _mutate(
    (thoughts) => [
      for (final t in thoughts) t.id == id ? t.copyWith(archived: value) : t,
    ],
  );

  /// Sérialise les mutations pour que chaque écriture parte de l’état
  /// effectivement enregistré par la précédente.
  Future<void> _mutate(List<Thought> Function(List<Thought>) change) {
    final result = _pending.then((_) async {
      if (!canMutate) {
        throw StateError('Le stockage n’est pas prêt.');
      }
      final next = List<Thought>.unmodifiable(change(_thoughts));
      _saving = true;
      notifyListeners();
      try {
        await storage.save(next);
        _thoughts = next;
      } finally {
        _saving = false;
        notifyListeners();
      }
    });
    _pending = result.catchError((_) {});
    return result;
  }

  static List<Thought> _sorted(Iterable<Thought> thoughts) =>
      thoughts.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static final _random = Random.secure();

  static String _randomId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final suffix = List.generate(
      8,
      (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return '$timestamp-$suffix';
  }
}
