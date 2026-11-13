import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/thought.dart';
import '../state/thought_inbox_controller.dart';
import 'load_error.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'thought_card.dart';
import 'toast.dart';

const _feedbackEmail = 'contact@pose-app.fr';
const _privacyUrl = 'https://pose-app.fr/privacy';
const _appVersion = '1.0.0';

/// Écran À traiter : pensées non traitées, de la plus récente à la plus
/// ancienne.
class InboxView extends StatefulWidget {
  const InboxView({
    super.key,
    required this.controller,
    required this.onCaptureTap,
  });

  final ThoughtInboxController controller;
  final VoidCallback onCaptureTap;

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  /// Réserve de la place sous la liste tant qu'un message est affiché.
  int _visibleToasts = 0;

  final _listKey = GlobalKey<SliverAnimatedListState>();

  /// Copie locale des pensées affichées ; reflète l'état animé de la liste.
  late List<Thought> _displayed;

  /// Dernier statut connu du contrôleur, pour détecter la transition initiale.
  late LoadStatus _prevStatus;

  static const _exitDuration = Duration(milliseconds: 280);
  static const _enterDuration = Duration(milliseconds: 180);

  ThoughtInboxController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _displayed = List.of(_controller.inbox);
    _prevStatus = _controller.status;
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;

    final wasReady = _prevStatus == LoadStatus.ready;
    final isReady = _controller.status == LoadStatus.ready;
    _prevStatus = _controller.status;

    if (!isReady) {
      setState(() {});
      return;
    }

    // Status is (or becomes) ready.
    if (!wasReady || _listKey.currentState == null) {
      // Initial load or list not yet in tree: sync without animation.
      setState(() => _displayed = List.of(_controller.inbox));
      return;
    }

    final next = _controller.inbox;
    final noAnim = MediaQuery.disableAnimationsOf(context);

    // Removals — iterate backwards so indices stay stable.
    for (var i = _displayed.length - 1; i >= 0; i--) {
      if (!next.any((t) => t.id == _displayed[i].id)) {
        final removed = _displayed.removeAt(i);
        _listKey.currentState!.removeItem(
          i,
          (ctx, anim) => _buildExitItem(removed, anim, noAnim),
          duration: noAnim ? Duration.zero : _exitDuration,
        );
      }
    }

    // Insertions (undo delete) — iterate forward for correct positions.
    for (var i = 0; i < next.length; i++) {
      if (!_displayed.any((t) => t.id == next[i].id)) {
        _displayed.insert(i, next[i]);
        _listKey.currentState!.insertItem(i, duration: _enterDuration);
      }
    }

    setState(() {});
  }

  /// Carte en sortie : fondu + effacement de hauteur vers le haut.
  Widget _buildExitItem(
    Thought thought,
    Animation<double> animation,
    bool skipAnim,
  ) {
    if (skipAnim) return const SizedBox.shrink();
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FadeTransition(
          opacity: animation,
          child: IgnorePointer(
            child: ThoughtCard(
              thought: thought,
              now: _controller.now,
              enabled: false,
              onMarkDone: () {},
            ),
          ),
        ),
      ),
    );
  }

  void _toast(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    if (!mounted) return;
    final toast = showToast(
      context,
      message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
    setState(() => _visibleToasts++);
    toast.closed.whenComplete(() {
      if (mounted) setState(() => _visibleToasts--);
    });
  }

  Future<void> _markDone(Thought thought) async {
    try {
      await _controller.archive(thought.id);
    } on Object {
      _toast('La pensée n’a pas pu être marquée traitée. Réessayez.');
      return;
    }
    _toast(
      'Pensée traitée.',
      actionLabel: 'Annuler',
      onAction: () => _undoMark(thought),
      duration: undoWindow,
    );
  }

  Future<void> _undoMark(Thought thought) async {
    try {
      await _controller.restore(thought.id);
    } on Object {
      _toast(
        "La pensée n’a pas pu être restaurée.",
        actionLabel: 'Réessayer',
        onAction: () => _undoMark(thought),
        duration: undoWindow,
      );
    }
  }

  Future<void> _delete(Thought thought) async {
    final Thought? removed;
    try {
      removed = await _controller.delete(thought.id);
    } on Object {
      _toast('La pensée n’a pas pu être supprimée. Réessayez.');
      return;
    }
    if (removed != null) _offerUndo(removed, 'Pensée supprimée.', 'Annuler');
  }

  void _offerUndo(Thought removed, String message, String actionLabel) {
    _toast(
      message,
      actionLabel: actionLabel,
      onAction: () => _undo(removed),
      duration: undoWindow,
    );
  }

  Future<void> _undo(Thought removed) async {
    try {
      await _controller.undoDelete(removed);
    } on Object {
      _offerUndo(removed, 'La pensée n’a pas pu être restaurée.', 'Réessayer');
    }
  }

  Future<void> _openAppMenu() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _launchFeedbackEmail();
            },
            child: const Text('Contacter le développeur'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _launchPrivacyUrl();
            },
            child: const Text('Confidentialité'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Version $_appVersion',
              style: const TextStyle(fontSize: 13, color: mutedForeground),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Fermer'),
        ),
      ),
    );
  }

  Future<void> _launchFeedbackEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      queryParameters: {'subject': 'Retour Posé'},
    );
    try {
      if (!await launchUrl(uri)) {
        _toast('Impossible d’ouvrir le client e-mail.');
      }
    } on Object {
      _toast('Impossible d’ouvrir le client e-mail.');
    }
  }

  Future<void> _launchPrivacyUrl() async {
    try {
      if (!await launchUrl(
        Uri.parse(_privacyUrl),
        mode: LaunchMode.externalApplication,
      )) {
        _toast('Impossible d’ouvrir la page de confidentialité.');
      }
    } on Object {
      _toast('Impossible d’ouvrir la page de confidentialité.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final insets = MediaQuery.paddingOf(context);
    final bottom = max(insets.bottom, 24.0) + (_visibleToasts > 0 ? 76 : 0);
    final ready = controller.status == LoadStatus.ready;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, max(insets.top, 20), 16, 0),
          sliver: SliverToBoxAdapter(
            child: _Header(
              count: controller.inbox.length,
              showCount: ready,
              onCaptureTap: widget.onCaptureTap,
              onMenuTap: _openAppMenu,
            ),
          ),
        ),
        if (!ready)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottom),
            sliver: SliverToBoxAdapter(
              child: controller.status == LoadStatus.failed
                  ? LoadError(controller: controller)
                  : Text('Chargement de vos pensées…', style: AppText.help),
            ),
          )
        else if (_displayed.isEmpty)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottom),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(onCaptureTap: widget.onCaptureTap),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
            sliver: SliverAnimatedList(
              key: _listKey,
              initialItemCount: _displayed.length,
              itemBuilder: (ctx, index, animation) {
                final thought = _displayed[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FadeTransition(
                    opacity: animation,
                    child: _SwipeToDeleteWrapper(
                      onDelete: () => _delete(thought),
                      child: ThoughtCard(
                        key: ValueKey(thought.id),
                        thought: thought,
                        now: controller.now,
                        enabled: !controller.isSaving,
                        onMarkDone: () => _markDone(thought),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SwipeToDeleteWrapper extends StatefulWidget {
  const _SwipeToDeleteWrapper({
    required this.onDelete,
    required this.child,
  });

  final VoidCallback onDelete;
  final Widget child;

  @override
  State<_SwipeToDeleteWrapper> createState() => _SwipeToDeleteWrapperState();
}

class _SwipeToDeleteWrapperState extends State<_SwipeToDeleteWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const _kButtonW = 80.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (d.delta.dx > 0 && _ctrl.value == 0) return;
    _ctrl.value = (_ctrl.value - d.delta.dx / _kButtonW).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!mounted) return;
    final vel = d.velocity.pixelsPerSecond.dx;
    final open = _ctrl.value > 0.5 || vel < -300;
    if (MediaQuery.disableAnimationsOf(context)) {
      _ctrl.value = open ? 1.0 : 0.0;
    } else {
      _ctrl.animateTo(open ? 1.0 : 0.0, curve: Curves.easeOut);
    }
  }

  void _delete() => widget.onDelete();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _ctrl,
        builder: (ctx, child) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_ctrl.value > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _delete,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: Container(
                        width: _kButtonW,
                        color: destructive,
                        alignment: Alignment.center,
                        child: Text(
                          'Supprimer',
                          style: AppText.button.copyWith(
                            color: const Color(0xFFFCFCFC),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(-_ctrl.value * _kButtonW, 0),
                child: child,
              ),
            ],
          ),
        ),
        child: widget.child,
      );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.showCount,
    required this.onCaptureTap,
    required this.onMenuTap,
  });

  final int count;
  final bool showCount;
  final VoidCallback onCaptureTap;
  final VoidCallback onMenuTap;

  /// Titre et compteur alignés sur la ligne de base ; empilés quand le texte
  /// est agrandi pour éviter de couper « À traiter ».
  Widget _titleRow(BuildContext context) {
    final title = Semantics(
      header: true,
      child: Text('À traiter', style: AppText.inboxTitle),
    );
    final pending = Text('$count en attente', style: AppText.pendingCount);
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          if (showCount) ...[const SizedBox(height: 8), pending],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: title),
        if (showCount) ...[const SizedBox(width: 12), pending],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Semantics(
                    button: true,
                    label: 'Capturer',
                    child: ExcludeSemantics(
                      child: InkWell(
                        onTap: onCaptureTap,
                        borderRadius: BorderRadius.circular(22),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.chevron_left,
                                size: 20,
                                color: primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Capturer',
                                  style: AppText.back,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(8, 0),
                  child: Semantics(
                    button: true,
                    label: 'Options',
                    child: ExcludeSemantics(
                      child: InkResponse(
                        onTap: onMenuTap,
                        radius: 22,
                        highlightShape: BoxShape.circle,
                        child: SizedBox.square(
                          dimension: 44,
                          child: Center(
                            child: const Icon(
                              CupertinoIcons.ellipsis,
                              size: 20,
                              color: mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _titleRow(context),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCaptureTap});

  final VoidCallback onCaptureTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomPaint(
            size: Size.square(64),
            painter: _DashedCirclePainter(),
          ),
          const SizedBox(height: 20),
          Text(
            'Esprit clair.',
            style: AppText.emptyTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Text(
              'Rien ne vous attend. Profitez du silence.',
              style: AppText.emptyBody,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onCaptureTap,
            style: FilledButton.styleFrom(
              backgroundColor: secondary,
              foregroundColor: secondaryForeground,
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: const StadiumBorder(),
              textStyle: AppText.emptyButton,
            ),
            child: const Text('Capturer une pensée'),
          ),
          // Équilibre optique : légèrement au-dessus du centre.
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}

/// Cercle pointillé décoratif de l'état vide.
class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = mutedForeground.withValues(alpha: .3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rect = Offset.zero & size;
    const dashes = 40;
    const sweep = 2 * pi / dashes;
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect.deflate(.5), i * sweep, sweep / 2, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) => false;
}
