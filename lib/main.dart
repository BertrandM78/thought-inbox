import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'state/thought_inbox_controller.dart';
import 'storage/onboarding_preference.dart';
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

  OnboardingPreference? onboardingPref;
  bool showOnboarding = false;
  try {
    onboardingPref = await OnboardingPreference.defaultLocation();
    // En mode debug uniquement : `--dart-define=RESET_ONBOARDING=true` supprime
    // le marqueur onboarding_done sans toucher aux pensées.
    if (kDebugMode &&
        const bool.fromEnvironment('RESET_ONBOARDING')) {
      await onboardingPref.reset();
    }
    showOnboarding = !(await onboardingPref.isDone());
  } on Object {
    // Si la préférence est inaccessible, ouvrir directement Capture.
  }

  final controller = ThoughtInboxController(storage: storage)..load();
  runApp(
    ThoughtInboxApp(
      controller: controller,
      showOnboarding: showOnboarding,
      onboardingPreference: onboardingPref,
    ),
  );
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
