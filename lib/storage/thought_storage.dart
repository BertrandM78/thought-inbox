import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

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
  FileThoughtStorage(this.file, {this.legacyFile});

  /// Emplacement par défaut dans le conteneur privé de l’application.
  static Future<FileThoughtStorage> defaultLocation() async {
    final directory = await getApplicationSupportDirectory();
    return FileThoughtStorage(
      File('${directory.path}/thoughts.json'),
      legacyFile: File('${directory.path}/thought_inbox/thoughts.json'),
    );
  }

  static const _formatVersion = 1;

  final File file;
  final File? legacyFile;

  @override
  Future<List<Thought>> load() async {
    final File source;
    try {
      if (await file.exists()) {
        source = file;
      } else if (legacyFile != null && await legacyFile!.exists()) {
        source = legacyFile!;
      } else {
        return [];
      }
    } on Object catch (error) {
      throw StorageReadException('Lecture du fichier impossible.', error);
    }

    final thoughts = await _read(source);
    if (source.path == file.path) return thoughts;

    try {
      await save(thoughts);
    } on Object catch (error) {
      throw StorageReadException('Migration des données impossible.', error);
    }
    return thoughts;
  }

  Future<List<Thought>> _read(File source) async {
    final String content;
    try {
      content = await source.readAsString();
    } on Object catch (error) {
      throw StorageReadException('Lecture du fichier impossible.', error);
    }
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
