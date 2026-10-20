import 'package:flutter/material.dart';

import 'state/thought_inbox_controller.dart';
import 'ui/home_page.dart';

/// Accent violet lavande de l’application.
const lavender = Color(0xFF8E7CC3);

class ThoughtInboxApp extends StatelessWidget {
  const ThoughtInboxApp({super.key, required this.controller});

  final ThoughtInboxController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thought Inbox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: lavender),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: lavender,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: HomePage(controller: controller),
    );
  }
}
