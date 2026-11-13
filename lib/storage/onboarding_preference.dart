import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Enregistre localement si l'onboarding a été vu.
/// Utilise un fichier marqueur dans le même répertoire que les pensées.
class OnboardingPreference {
  OnboardingPreference(this._file);

  static Future<OnboardingPreference> defaultLocation() async {
    final dir = await getApplicationSupportDirectory();
    return OnboardingPreference(File('${dir.path}/onboarding_done'));
  }

  final File _file;

  Future<bool> isDone() async {
    try {
      return await _file.exists();
    } on Object {
      return false;
    }
  }

  /// Lève une exception si l'écriture échoue.
  Future<void> markDone() => _file.writeAsString('1');

  /// Supprime le marqueur pour que l'onboarding soit affiché au prochain
  /// lancement. Sans effet si le fichier n'existe pas.
  Future<void> reset() async {
    if (await _file.exists()) await _file.delete();
  }
}
