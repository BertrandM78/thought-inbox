import 'dart:convert';
import 'dart:io';

import '../models/thought.dart';

/// Erreur de lecture : les données existantes n’ont pas pu être chargées.
/// Elles ne doivent pas être écrasées.
class StorageReadException implements Exception {
  const StorageReadException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'StorageReadException: $message (${cause ?? '-'})';
}

/// Erreur d’écriture : la dernière modification n’a pas été enregistrée.
class StorageWriteException implements Exception {
  const StorageWriteException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'StorageWriteException: $message (${cause ?? '-'})';
}

/// Stockage de l’ensemble des pensées, injectable pour les tests.
abstract interface class ThoughtStorage {
  /// Retourne les pensées enregistrées, ou une liste vide si rien n’a encore
  /// été enregistré. Lève [StorageReadException] si les données sont
  /// illisibles.
  Future<List<Thought>> load();

  /// Remplace les pensées enregistrées. Lève [StorageWriteException] en cas
  /// d’échec.
  Future<void> save(List<Thought> thoughts);
}

/// Stockage utilisé lorsque l’emplacement local n’a pas pu être déterminé :
/// chaque opération échoue explicitement.
class UnavailableThoughtStorage implements ThoughtStorage {
  const UnavailableThoughtStorage(this.reason);

  final Object reason;

  @override
  Future<List<Thought>> load() async =>
      throw StorageReadException('Stockage indisponible.', reason);

  @override
  Future<void> save(List<Thought> thoughts) async =>
      throw StorageWriteException('Stockage indisponible.', reason);
}

/// Stockage local dans un fichier JSON, écrit de façon atomique
/// (fichier temporaire puis renommage).
///
/// Ce fichier n’est ni chiffré ni sauvegardé par l’application.
class FileThoughtStorage implements ThoughtStorage {
  FileThoughtStorage(this.file);

  /// Emplacement par défaut, dans le conteneur de l’application
  /// (`Library/Application Support` sur iOS).
  factory FileThoughtStorage.defaultLocation() {
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      throw const StorageReadException('Dossier de l’application introuvable.');
    }
    return FileThoughtStorage(
      File('$home/Library/Application Support/thought_inbox/thoughts.json'),
    );
  }

  static const _formatVersion = 1;

  final File file;

  @override
  Future<List<Thought>> load() async {
    final String? content;
    try {
      content = await file.exists() ? await file.readAsString() : null;
    } on Object catch (error) {
      throw StorageReadException('Lecture du fichier impossible.', error);
    }
    if (content == null) return [];
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Objet racine attendu.');
      }
      final version = decoded['version'];
      if (version != _formatVersion) {
        throw FormatException('Version de format inconnue : $version.');
      }
      final list = decoded['thoughts'];
      if (list is! List<Object?>) {
        throw const FormatException('Liste de pensées attendue.');
      }
      return [for (final item in list) Thought.fromJson(item)];
    } on Object catch (error) {
      throw StorageReadException('Données illisibles.', error);
    }
  }

  @override
  Future<void> save(List<Thought> thoughts) async {
    final temp = File('${file.path}.tmp');
    try {
      await file.parent.create(recursive: true);
      final content = jsonEncode({
        'version': _formatVersion,
        'thoughts': [for (final thought in thoughts) thought.toJson()],
      });
      await temp.writeAsString(content, flush: true);
      await temp.rename(file.path);
    } on Object catch (error) {
      throw StorageWriteException('Écriture du fichier impossible.', error);
    }
  }
}
