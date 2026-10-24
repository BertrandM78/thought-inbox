import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'state/thought_inbox_controller.dart';
import 'storage/thought_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_fontLicenses);
  ThoughtStorage storage;
  try {
    storage = await FileThoughtStorage.defaultLocation();
  } on Object catch (error) {
    storage = UnavailableThoughtStorage(error);
  }
  final controller = ThoughtInboxController(storage: storage)..load();
  runApp(ThoughtInboxApp(controller: controller));
}

/// Licences OFL des polices embarquées.
Stream<LicenseEntry> _fontLicenses() async* {
  for (final (family, file) in [
    ('Newsreader', 'OFL-Newsreader.txt'),
    ('Inter Tight', 'OFL-InterTight.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks([
      family,
    ], await rootBundle.loadString('assets/fonts/$file'));
  }
}
