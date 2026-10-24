import 'dart:math';

import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

/// Durée pendant laquelle « Annuler » reste disponible après une suppression.
const undoWindow = Duration(seconds: 5);

const _messageDuration = Duration(seconds: 4);

/// Affiche un message temporaire graphite en bas de l’écran courant. Il
/// remplace immédiatement le message précédent, dont l’action n’est alors
/// plus disponible.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  messenger.removeCurrentSnackBar();
  return messenger.showSnackBar(
    SnackBar(
      // Le Scaffold place déjà le message au-dessus de la zone sûre.
      margin: EdgeInsets.fromLTRB(16, 0, 16, max(0, 20 - bottomInset)),
      padding: const EdgeInsetsDirectional.only(start: 20, end: 8),
      duration: duration ?? _messageDuration,
      // Expire même avec une action : la fenêtre d’annulation est bornée.
      persist: false,
      content: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(message, style: AppText.toast),
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar(
                    reason: SnackBarClosedReason.action,
                  );
                  onAction?.call();
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  overlayColor: Colors.white,
                ),
                child: Text(actionLabel, style: AppText.toastAction),
              ),
          ],
        ),
      ),
    ),
  );
}
