import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../state/thought_inbox_controller.dart';
import '../storage/thought_storage.dart';
import 'load_error.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'toast.dart';

/// Écran Capture : saisie libre et dépôt. Le brouillon vit dans cet état et
/// survit aux allers-retours vers À traiter.
class CaptureView extends StatefulWidget {
  const CaptureView({
    super.key,
    required this.controller,
    required this.onInboxTap,
  });

  final ThoughtInboxController controller;
  final VoidCallback onInboxTap;

  @override
  State<CaptureView> createState() => _CaptureViewState();
}

class _CaptureViewState extends State<CaptureView> {
  final _text = TextEditingController();

  /// Vrai dès l’appui sur « Déposer », avant même que le contrôleur ne
  /// signale l’écriture : empêche un second dépôt par appuis rapides.
  bool _submitting = false;

  /// Confirmation affichée après une sauvegarde réussie, jusqu’à la frappe
  /// suivante.
  bool _justSaved = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting &&
      widget.controller.canMutate &&
      !widget.controller.isSaving &&
      _text.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final submitted = _text.text;
    setState(() => _submitting = true);
    try {
      await widget.controller.add(submitted);
      if (!mounted) return;
      setState(() {
        _justSaved = true;
        // Ne vide le champ que s’il n’a pas changé pendant l’écriture.
        if (_text.text == submitted) _text.clear();
      });
    } on Object catch (error) {
      if (!mounted) return;
      showToast(
        context,
        error is StorageWriteException
            ? 'La pensée n’a pas été enregistrée. Votre texte est conservé.'
            : 'Impossible d’enregistrer pour le moment. '
                  'Votre texte est conservé.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final insets = MediaQuery.paddingOf(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final padding = EdgeInsets.fromLTRB(
      24,
      max(insets.top, 20),
      24,
      max(insets.bottom, 24),
    );
    // Occupe au moins l’écran ; défile si le contenu (clavier, texte agrandi)
    // dépasse.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: max(0, constraints.maxHeight - padding.vertical),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                count: controller.inbox.length,
                onInboxTap: widget.onInboxTap,
              ),
              Padding(
                // Remonte le corps quand le clavier est fermé (source : 96) ;
                // inutile une fois le clavier ouvert.
                padding: EdgeInsets.only(
                  top: 24,
                  bottom: keyboardOpen ? 24 : 96,
                ),
                child: _body(controller),
              ),
              Text(
                'Traitez plus tard, l’esprit libre.',
                textAlign: TextAlign.center,
                style: AppText.footer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(ThoughtInboxController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('CAPTUREZ MAINTENANT', style: AppText.eyebrow),
        const SizedBox(height: 16),
        TextField(
          controller: _text,
          minLines: 4,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          keyboardAppearance: Brightness.light,
          textCapitalization: TextCapitalization.sentences,
          style: AppText.captureInput,
          cursorColor: primary,
          decoration: InputDecoration(
            hintText: 'Qu’avez-vous en tête ?',
            hintStyle: AppText.capturePlaceholder,
            isCollapsed: true,
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() => _justSaved = false),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(child: _helpText()),
              const SizedBox(width: 12),
              _DepositButton(onPressed: _canSubmit ? _submit : null),
            ],
          ),
        ),
        if (controller.status == LoadStatus.failed) ...[
          const SizedBox(height: 16),
          LoadError(controller: controller),
        ],
      ],
    );
  }

  Widget _helpText() {
    if (_justSaved) {
      return Semantics(
        liveRegion: true,
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text('Déposé. Vous y reviendrez.', style: AppText.help),
            ),
          ],
        ),
      );
    }
    final length = _text.text.characters.length;
    return Text(
      length == 0
          ? 'Pas de titre, pas de tri.'
          : '$length caractère${length > 1 ? 's' : ''}',
      style: AppText.help,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.onInboxTap});

  final int count;
  final VoidCallback onInboxTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              label: 'Posé',
              child: ExcludeSemantics(
                child: Text('posé.', style: AppText.logotype),
              ),
            ),
          ),
          // Aligne la zone tactile sur la marge droite (source : −8).
          Transform.translate(
            offset: const Offset(8, 0),
            child: Semantics(
              button: true,
              label: count == 0
                  ? 'À traiter, aucune pensée en attente'
                  : 'À traiter, $count en attente',
              child: ExcludeSemantics(
                child: InkResponse(
                  onTap: onInboxTap,
                  radius: 22,
                  highlightShape: BoxShape.circle,
                  child: SizedBox.square(
                    dimension: 44,
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            CupertinoIcons.tray,
                            size: 24,
                            color: foreground,
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            top: 6,
                            right: 4,
                            child: _Badge(count: count),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        '$count',
        style: AppText.badge,
        textScaler: TextScaler.noScaling,
      ),
    );
  }
}

class _DepositButton extends StatelessWidget {
  const _DepositButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: primaryForeground,
        disabledBackgroundColor: secondary,
        disabledForegroundColor: mutedForeground,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const StadiumBorder(),
        textStyle: AppText.button,
      ),
      child: const Text('Déposer'),
    );
  }
}
