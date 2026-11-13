import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'state/thought_inbox_controller.dart';
import 'storage/onboarding_preference.dart';
import 'ui/home_page.dart';
import 'ui/onboarding_view.dart';
import 'ui/theme/app_theme.dart';

class ThoughtInboxApp extends StatelessWidget {
  const ThoughtInboxApp({
    super.key,
    required this.controller,
    this.showOnboarding = false,
    this.onboardingPreference,
  });

  final ThoughtInboxController controller;

  /// Vrai uniquement au premier lancement (déterminé dans main).
  final bool showOnboarding;

  /// Null si la préférence est inaccessible ; dans ce cas l’onboarding ne s’affiche pas.
  final OnboardingPreference? onboardingPreference;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posé',
      debugShowCheckedModeBanner: false,
      // Thème clair uniquement, même si l’iPhone est en mode sombre.
      theme: buildAppTheme(),
      themeMode: ThemeMode.light,
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: showOnboarding && onboardingPreference != null
          ? OnboardingView(
              controller: controller,
              preference: onboardingPreference!,
            )
          : HomePage(controller: controller),
    );
  }
}
