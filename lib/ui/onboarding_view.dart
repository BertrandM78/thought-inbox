import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/thought_inbox_controller.dart';
import '../storage/onboarding_preference.dart';
import 'home_page.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

/// Écran d'accueil affiché uniquement au premier lancement.
/// Une seule page, défilable sur petits écrans ou grands textes.
class OnboardingView extends StatefulWidget {
  const OnboardingView({
    super.key,
    required this.controller,
    required this.preference,
  });

  final ThoughtInboxController controller;
  final OnboardingPreference preference;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  bool _starting = false;

  Future<void> _start() async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      await widget.preference.markDone();
    } on Object {
      // Si l’écriture échoue, l’onboarding réapparaît au prochain lancement.
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, anim, _) => HomePage(controller: widget.controller),
        transitionsBuilder: (ctx, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    final padding = EdgeInsets.fromLTRB(
      24,
      max(insets.top, 24),
      24,
      max(insets.bottom, 32),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: LayoutBuilder(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(),
                      const SizedBox(height: 36),
                      _Features(),
                    ],
                  ),
                  _Footer(onStart: _starting ? null : _start),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/branding/pose-feather-silhouette-transparent-1024.png',
          width: 56,
          height: 56,
          semanticLabel: 'Logo Posé',
        ),
        const SizedBox(height: 20),
        Text(
          'Bienvenue sur posé.',
          textAlign: TextAlign.center,
          style: AppText.emptyTitle.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 10),
        Text(
          'Libérez votre attention, sans perdre vos idées.',
          textAlign: TextAlign.center,
          style: AppText.help,
        ),
      ],
    );
  }
}

class _Features extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FeatureRow(
          icon: CupertinoIcons.pencil,
          title: 'Déposez vos pensées',
          body: 'Une idée en tête ? Notez-la en quelques secondes.',
        ),
        const SizedBox(height: 28),
        _FeatureRow(
          icon: CupertinoIcons.tray,
          title: 'Retrouvez-les plus tard',
          body: 'Toutes vos pensées vous attendent au même endroit.',
        ),
        const SizedBox(height: 28),
        _FeatureRow(
          icon: CupertinoIcons.checkmark_circle,
          title: 'Traitez-les à votre rythme',
          body: 'Quand le moment est venu, cochez et passez à autre chose.',
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 22, color: primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.back.copyWith(color: foreground)),
              const SizedBox(height: 4),
              Text(body, style: AppText.help),
            ],
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onStart});

  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: onStart,
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: primaryForeground,
            disabledBackgroundColor: secondary,
            disabledForegroundColor: mutedForeground,
            minimumSize: const Size(double.infinity, 48),
            shape: const StadiumBorder(),
            textStyle: AppText.button,
          ),
          child: const Text('Commencer'),
        ),
        const SizedBox(height: 14),
        Text(
          'Sans compte. Vos pensées restent sur votre appareil.',
          textAlign: TextAlign.center,
          style: AppText.footer,
        ),
      ],
    );
  }
}
