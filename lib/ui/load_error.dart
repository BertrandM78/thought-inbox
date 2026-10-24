import 'package:flutter/material.dart';

import '../state/thought_inbox_controller.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Échec de lecture : rien n’a été écrit, l’utilisateur peut réessayer.
class LoadError extends StatelessWidget {
  const LoadError({super.key, required this.controller});

  final ThoughtInboxController controller;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Vos pensées n’ont pas pu être chargées. '
              'Les données existantes n’ont pas été modifiées.',
              style: AppText.help,
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: controller.load,
            style: TextButton.styleFrom(
              foregroundColor: primary,
              minimumSize: const Size(44, 44),
              textStyle: AppText.back,
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
