import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/thought.dart';
import '../state/thought_inbox_controller.dart';
import 'load_error.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'thought_card.dart';
import 'toast.dart';

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
              onMenu: () {},
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

  Future<void> _openMenu(Thought thought) async {
    final action = await showThoughtActions(context, thought);
    switch (action) {
      case ThoughtAction.markDone:
        await _markDone(thought);
      case ThoughtAction.delete:
        await _delete(thought);
      case null:
        break;
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
                    child: ThoughtCard(
                      key: ValueKey(thought.id),
                      thought: thought,
                      now: controller.now,
                      enabled: !controller.isSaving,
                      onMarkDone: () => _markDone(thought),
                      onMenu: () => _openMenu(thought),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.showCount,
    required this.onCaptureTap,
  });

  final int count;
  final bool showCount;
  final VoidCallback onCaptureTap;

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
          Semantics(
            button: true,
            label: 'Capturer',
            child: ExcludeSemantics(
              child: InkWell(
                onTap: onCaptureTap,
                borderRadius: BorderRadius.circular(22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
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
                        Flexible(child: Text('Capturer', style: AppText.back)),
                      ],
                    ),
                  ),
                ),
              ),
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
