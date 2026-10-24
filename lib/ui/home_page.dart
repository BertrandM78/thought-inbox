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

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  void _show(int tab) {
    // Un message temporaire appartient à l’écran qui l’a affiché.
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) => IndexedStack(
            index: _tab,
            children: [
              CaptureView(
                controller: widget.controller,
                onInboxTap: () => _show(1),
              ),
              InboxView(
                controller: widget.controller,
                onCaptureTap: () => _show(0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
