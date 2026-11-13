import 'dart:async';
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

  /// Vrai dès l'appui sur « Déposer », avant même que le contrôleur ne
  /// signale l'écriture : empêche un second dépôt par appuis rapides.
  bool _submitting = false;

  /// Confirmation affichée après une sauvegarde réussie, jusqu'à la frappe
  /// suivante.
  bool _justSaved = false;

  final _badgeKey = GlobalKey<_AnimatedBadgeState>();
  final _depositKey = GlobalKey();
  Timer? _badgePulseTimer;
  OverlayEntry? _flyEntry;

  @override
  void dispose() {
    _text.dispose();
    _badgePulseTimer?.cancel();
    _flyEntry?.remove();
    _flyEntry = null;
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
        // Ne vide le champ que s'il n'a pas changé pendant l'écriture.
        if (_text.text == submitted) _text.clear();
      });
      _startAnimations();
    } on Object catch (error) {
      if (!mounted) return;
      showToast(
        context,
        error is StorageWriteException
            ? "La pensée n’a pas été enregistrée. Votre texte est conservé."
            : "Impossible d’enregistrer pour le moment. "
                  "Votre texte est conservé.",
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// Lance la particule volante et programme le rebond du badge.
  /// Sans effet si « Réduire les animations » est actif.
  void _startAnimations() {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    _triggerFly();
    _badgePulseTimer?.cancel();
    _badgePulseTimer = Timer(const Duration(milliseconds: 450), _pulseBadge);
  }

  void _triggerFly() {
    final depositBox =
        _depositKey.currentContext?.findRenderObject() as RenderBox?;
    if (depositBox == null) return;

    final start = depositBox.localToGlobal(
      Offset(depositBox.size.width / 2, depositBox.size.height / 2),
    );
    final badgeBox = _badgeKey.currentContext?.findRenderObject() as RenderBox?;
    final end = badgeBox != null
        ? badgeBox.localToGlobal(
            Offset(badgeBox.size.width / 2, badgeBox.size.height / 2),
          )
        : start + const Offset(80, -100);

    _flyEntry?.remove();
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyDot(
        start: start,
        end: end,
        onDone: () {
          entry.remove();
          if (mounted) _flyEntry = null;
        },
      ),
    );
    _flyEntry = entry;
    Overlay.of(context).insert(entry);
  }

  void _pulseBadge() {
    _badgePulseTimer = null;
    _badgeKey.currentState?.pulse();
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
    // Occupe au moins l'écran ; défile si le contenu (clavier, texte agrandi)
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
                badgeKey: _badgeKey,
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
                "Traitez plus tard, l’esprit libre.",
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
            hintText: "Qu’avez-vous en tête ?",
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
              SizedBox(
                key: _depositKey,
                child: _DepositButton(onPressed: _canSubmit ? _submit : null),
              ),
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
  // ignore: prefer_const_constructors_in_immutables
  _Header({
    required this.count,
    required this.onInboxTap,
    required this.badgeKey,
  });

  final int count;
  final VoidCallback onInboxTap;
  final GlobalKey<_AnimatedBadgeState> badgeKey;

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
                            child: _AnimatedBadge(key: badgeKey, count: count),
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

/// Badge compteur avec rebond ressort au dépôt d'une pensée.
class _AnimatedBadge extends StatefulWidget {
  const _AnimatedBadge({super.key, required this.count});

  final int count;

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // Démarre à value 1.0 (taille normale) ; pulse() lance le rebond.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );
    _scale = Tween<double>(
      begin: 1.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
  }

  /// Déclenche le rebond : 1,4× → 1,0× avec ressort (Curves.elasticOut).
  void pulse() {
    _ctrl.reset();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          '${widget.count}',
          style: AppText.badge,
          textScaler: TextScaler.noScaling,
        ),
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

/// Particule lavande qui vole du bouton « Déposer » vers le compteur inbox.
/// Courbe Cubic(0,6, 0, 0,3, 1), 600 ms, échelle 1→0,2 et opacité 1→0.
class _FlyDot extends StatefulWidget {
  const _FlyDot({required this.start, required this.end, required this.onDone});

  final Offset start;
  final Offset end;
  final VoidCallback onDone;

  @override
  State<_FlyDot> createState() => _FlyDotState();
}

class _FlyDotState extends State<_FlyDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _curve = Cubic(0.6, 0, 0.3, 1);
  static const _dotRadius = 6.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _curve.transform(_ctrl.value);
        final dx = widget.start.dx + (widget.end.dx - widget.start.dx) * t;
        final dy = widget.start.dy + (widget.end.dy - widget.start.dy) * t;
        final scale = (1.0 + (0.2 - 1.0) * t).clamp(0.0, 1.0);
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        return Positioned(
          left: dx - _dotRadius,
          top: dy - _dotRadius,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: _dotRadius * 2,
                  height: _dotRadius * 2,
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
