import 'package:flutter/material.dart';

import '../models/thought.dart';
import '../state/thought_inbox_controller.dart';
import '../storage/thought_storage.dart';
import 'date_format.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});

  final ThoughtInboxController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tab == 0 ? 'Inbox' : 'Archives')),
      body: ListenableBuilder(
        listenable: widget.controller,
        // Les deux onglets restent montés pour conserver la saisie en cours.
        builder: (context, _) => IndexedStack(
          index: _tab,
          children: [
            _InboxView(controller: widget.controller),
            _ArchiveView(controller: widget.controller),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive_outlined),
            selectedIcon: Icon(Icons.archive),
            label: 'Archives',
          ),
        ],
      ),
    );
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _InboxView extends StatelessWidget {
  const _InboxView({required this.controller});

  final ThoughtInboxController controller;

  @override
  Widget build(BuildContext context) {
    final thoughts = controller.inbox;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Composer(controller: controller),
        const SizedBox(height: 24),
        if (controller.status != LoadStatus.ready)
          _LoadState(controller: controller)
        else if (thoughts.isEmpty)
          const _EmptyState(
            icon: Icons.lightbulb_outline,
            message:
                'Votre inbox est vide.\n'
                'Écrivez ce qui vous traverse l’esprit, '
                'vous y reviendrez plus tard.',
          )
        else
          for (final thought in thoughts)
            _ThoughtCard(
              key: ValueKey(thought.id),
              thought: thought,
              actionLabel: 'Archiver',
              actionIcon: Icons.archive_outlined,
              enabled: !controller.isSaving,
              onAction: () async {
                try {
                  await controller.archive(thought.id);
                } on Object {
                  if (context.mounted) {
                    _showError(
                      context,
                      'La pensée n’a pas pu être archivée. Réessayez.',
                    );
                  }
                }
              },
            ),
      ],
    );
  }
}

class _ArchiveView extends StatelessWidget {
  const _ArchiveView({required this.controller});

  final ThoughtInboxController controller;

  @override
  Widget build(BuildContext context) {
    final thoughts = controller.archived;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (controller.status != LoadStatus.ready)
          _LoadState(controller: controller)
        else if (thoughts.isEmpty)
          const _EmptyState(
            icon: Icons.archive_outlined,
            message:
                'Aucune pensée archivée.\n'
                'Les pensées archivées depuis l’inbox apparaîtront ici.',
          )
        else
          for (final thought in thoughts)
            _ThoughtCard(
              key: ValueKey(thought.id),
              thought: thought,
              actionLabel: 'Restaurer',
              actionIcon: Icons.unarchive_outlined,
              enabled: !controller.isSaving,
              onAction: () async {
                try {
                  await controller.restore(thought.id);
                } on Object {
                  if (context.mounted) {
                    _showError(
                      context,
                      'La pensée n’a pas pu être restaurée. Réessayez.',
                    );
                  }
                }
              },
            ),
      ],
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer({required this.controller});

  final ThoughtInboxController controller;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _text = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = widget.controller;
    if (!controller.canMutate || controller.isSaving) return;
    final submitted = _text.text;
    try {
      final result = await controller.add(submitted);
      if (!mounted) return;
      setState(() {
        if (result == AddResult.empty) {
          _error = 'Écrivez quelque chose avant de déposer.';
        } else {
          _error = null;
          // Ne vide le champ que s’il n’a pas changé pendant l’écriture.
          if (_text.text == submitted) _text.clear();
        }
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = null);
      _showError(
        context,
        error is StorageWriteException
            ? 'La pensée n’a pas été enregistrée. Votre texte est conservé.'
            : 'Impossible d’enregistrer pour le moment. '
                  'Votre texte est conservé.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final enabled = controller.canMutate && !controller.isSaving;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _text,
          minLines: 3,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Nouvelle pensée',
            hintText: 'Qu’avez-vous en tête ?',
            alignLabelWithHint: true,
            errorText: _error,
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: enabled ? _submit : null,
          icon: const Icon(Icons.add),
          label: const Text('Déposer'),
        ),
      ],
    );
  }
}

class _LoadState extends StatelessWidget {
  const _LoadState({required this.controller});

  final ThoughtInboxController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.status == LoadStatus.loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement de vos pensées…'),
            ],
          ),
        ),
      );
    }
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vos pensées n’ont pas pu être chargées. '
              'Les données existantes n’ont pas été modifiées.',
              style: TextStyle(color: colors.onErrorContainer),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.load,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 48, color: colors.primary),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ThoughtCard extends StatelessWidget {
  const _ThoughtCard({
    super.key,
    required this.thought,
    required this.actionLabel,
    required this.actionIcon,
    required this.enabled,
    required this.onAction,
  });

  final Thought thought;
  final String actionLabel;
  final IconData actionIcon;
  final bool enabled;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(thought.text, style: textTheme.bodyLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatThoughtDate(thought.createdAt),
                    style: textTheme.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: enabled ? onAction : null,
                  icon: Icon(actionIcon),
                  label: Text(actionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
