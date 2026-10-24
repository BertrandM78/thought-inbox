import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'state/thought_inbox_controller.dart';
import 'ui/home_page.dart';
import 'ui/theme/app_theme.dart';

class ThoughtInboxApp extends StatelessWidget {
  const ThoughtInboxApp({super.key, required this.controller});

  final ThoughtInboxController controller;

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
      home: HomePage(controller: controller),
    );
  }
}
