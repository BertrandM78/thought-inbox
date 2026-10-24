import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/thought.dart';
import 'date_format.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

enum ThoughtAction { markDone, delete }

/// Carte d’une pensée à traiter : cercle « Marquer traitée », texte entier,
/// date relative et menu d’actions.
class ThoughtCard extends StatelessWidget {
  const ThoughtCard({
    super.key,
    required this.thought,
    required this.now,
    required this.enabled,
    required this.onMarkDone,
    required this.onMenu,
  });

  final Thought thought;
  final DateTime now;
  final bool enabled;
  final VoidCallback onMarkDone;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cercle visuel de 22 à 16 du bord, zone tactile de 44.
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 8),
            child: _TapTarget(
              label: 'Marquer traitée',
              onTap: enabled ? onMarkDone : null,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: mutedForeground.withValues(alpha: quietAlpha),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(thought.text, style: AppText.thought),
                  const SizedBox(height: 8),
                  Text(
                    formatRelativeThoughtDate(thought.createdAt, now: now),
                    style: AppText.date,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8, left: 4),
            child: _TapTarget(
              label: 'Actions pour cette pensée',
              onTap: enabled ? onMenu : null,
              child: const Icon(
                CupertinoIcons.ellipsis,
                size: 20,
                color: mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TapTarget extends StatelessWidget {
  const _TapTarget({
    required this.label,
    required this.onTap,
    required this.child,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          highlightShape: BoxShape.circle,
          child: SizedBox.square(dimension: 44, child: Center(child: child)),
        ),
      ),
    );
  }
}

/// Feuille d’actions d’une pensée : « Marquer traitée », « Supprimer »,
/// « Fermer ». Retourne l’action choisie, ou `null`.
Future<ThoughtAction?> showThoughtActions(
  BuildContext context,
  Thought thought,
) {
  return showModalBottomSheet<ThoughtAction>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: foreground.withValues(alpha: .25),
    elevation: 0,
    isScrollControlled: true,
    builder: (context) {
      final bottom = max(MediaQuery.paddingOf(context).bottom, 8.0);
      return Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetBlock(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Text(
                    thought.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppText.sheetPreview,
                  ),
                ),
                _SheetRow(
                  label: 'Marquer traitée',
                  style: AppText.sheetAction.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w500,
                    fontVariations: const [FontVariation('wght', 500)],
                  ),
                  onTap: () => Navigator.pop(context, ThoughtAction.markDone),
                ),
                _SheetRow(
                  label: 'Supprimer',
                  style: AppText.sheetAction.copyWith(color: destructive),
                  onTap: () => Navigator.pop(context, ThoughtAction.delete),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SheetBlock(
              children: [
                _SheetRow(
                  label: 'Fermer',
                  style: AppText.sheetClose,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _SheetBlock extends StatelessWidget {
  const _SheetBlock({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: card,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: border),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Center(
              child: Text(label, style: style, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
