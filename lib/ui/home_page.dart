import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/thought_inbox_controller.dart';
import 'capture_view.dart';
import 'inbox_view.dart';

/// Deux écrans seulement : Capture (au lancement) et À traiter. Les deux
/// restent montés pour conserver le brouillon pendant la session.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});

  final ThoughtInboxController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  bool _animating = false;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _captureSlide;
  late final Animation<Offset> _inboxSlide;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final curve = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeInOut);
    _captureSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(curve);
    _inboxSlide = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(curve);
    // Expose animation state so Offstage lifts during the transition.
    _slideCtrl.addStatusListener((status) {
      if (!mounted) return;
      final nowAnimating =
          status == AnimationStatus.forward ||
          status == AnimationStatus.reverse;
      if (nowAnimating != _animating) setState(() => _animating = nowAnimating);
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _show(int tab) {
    if (tab == _tab) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _tab = tab);
    final skipAnim = MediaQuery.disableAnimationsOf(context);
    if (tab == 1) {
      skipAnim ? _slideCtrl.value = 1.0 : _slideCtrl.forward();
    } else {
      skipAnim ? _slideCtrl.value = 0.0 : _slideCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // During transition both views are on-screen; at rest the inactive view
    // is offstage (preserves state, excluded from widget finders — same
    // behaviour as the previous IndexedStack).
    final captureOffstage = !_animating && _tab == 1;
    final inboxOffstage = !_animating && _tab == 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) => Stack(
            children: [
              SlideTransition(
                position: _captureSlide,
                child: Offstage(
                  offstage: captureOffstage,
                  child: IgnorePointer(
                    ignoring: _tab == 1,
                    child: CaptureView(
                      controller: widget.controller,
                      onInboxTap: () => _show(1),
                    ),
                  ),
                ),
              ),
              SlideTransition(
                position: _inboxSlide,
                child: Offstage(
                  offstage: inboxOffstage,
                  child: IgnorePointer(
                    ignoring: _tab == 0,
                    child: InboxView(
                      controller: widget.controller,
                      onCaptureTap: () => _show(0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
