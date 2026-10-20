# Thought Inbox

**Un endroit calme pour déposer une pensée, puis y revenir.**

Thought Inbox est un projet personnel d’application mobile Flutter. Son ambition : capturer une idée au moment où elle arrive, sans devoir immédiatement la classer ou la transformer en tâche.

> En développement. Ce dépôt expose la démarche produit et la progression du prototype ; aucune version distribuée sur l’App Store n’est encore disponible.

## Le premier parcours

1. Écrire une pensée et l’ajouter à l’inbox.
2. Retrouver les pensées récentes en premier.
3. Archiver une pensée et la restaurer si nécessaire.
4. Retrouver ses données après avoir fermé puis relancé l’application.

L’interface vise une expérience simple, en français, avec un accent violet lavande. Les données du prototype restent sur l’appareil, sans compte ni service distant. Le stockage local de ce premier jalon n’est pas un coffre chiffré ni une sauvegarde ; désinstaller l’application peut effacer les données.

## État du projet

Le premier milestone est spécifié dans [PRODUCT.md](docs/PRODUCT.md). La saisie, l’inbox, les archives et la persistance dans un fichier JSON local sont implémentées. **27 tests automatisés passent et l’analyse statique Dart ne signale aucun problème. Le parcours sur simulateur iOS reste à valider**, en particulier la conservation des données après fermeture complète. L’état détaillé est consigné dans [MILESTONE-1.md](docs/MILESTONE-1.md).

Les idées suivantes restent hors de ce premier jalon : synchronisation, IA, notifications, capture vocale, tags et monétisation. Elles ne constituent pas des fonctionnalités disponibles ou promises.

## Lancer le projet

Prérequis : Flutter stable compatible avec la contrainte Dart de `pubspec.yaml` (Dart `^3.13.5`), et Xcode pour le simulateur iOS. Seule la cible iOS est actuellement incluse dans le dépôt.

```sh
git clone https://github.com/BertrandM78/thought-inbox.git
cd thought-inbox
flutter pub get
flutter devices
flutter run -d <identifiant-du-simulateur>
```

## Vérifier une modification

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Organisation

- `lib/` : application Dart/Flutter — `models/` (pensée), `storage/` (stockage fichier), `state/` (état de l’inbox), `ui/` (écrans).
- `test/` : tests automatisés.
- `ios/` : intégration native iOS.
- [docs/PRODUCT.md](docs/PRODUCT.md) : vision, périmètre et critères d’acceptation.
- [CLAUDE.md](CLAUDE.md) : contexte et règles de travail pour Claude Code.
- [docs/FIRST-PROMPT.md](docs/FIRST-PROMPT.md) : brief reproductible du premier milestone.

## Pourquoi partager ce travail

Ce projet documente le passage d’une intention produit à une application utilisable : cadrage, expérience mobile, persistance locale et vérification. Le périmètre reste volontairement réduit pour terminer des parcours concrets avant d’ajouter des fonctionnalités.

Les retours sur l’usage, la simplicité et l’accessibilité sont les bienvenus dans les issues. Merci de ne pas y publier de pensées personnelles ni d’informations sensibles.
