# Posé

**Libérer l’attention sans perdre les idées.**

Posé permet de déposer une pensée immédiatement et de la retrouver plus tard. La V1 vise une publication rapide sur l’App Store : iOS ≥17, français, stockage local et deux écrans simples, Capture et À traiter. Ancien nom du projet : Thought Inbox ; dossier et package Flutter : `thought_inbox`.

## État du projet — 24 octobre 2026

L’app comporte les deux écrans de la V1 : Capture (dépôt, confirmation après sauvegarde) et À traiter (liste chronologique, « Marquer traitée », suppression avec « Annuler » pendant cinq secondes). Identité Posé, polices Newsreader et Inter Tight embarquées, palette validée, thème clair forcé. Stockage JSON local via `path_provider`, persistance vérifiée après relancement sur simulateur iOS.

L’icône iOS utilise la plume silhouette de `assets/branding/` ; minimum iOS 17.0, iPhone et portrait uniquement. Restent avant publication : VoiceOver et essais sur appareil réel, signature, TestFlight et fiche App Store. Détails et preuves dans [MVP](docs/MVP.md).

Le détail des écarts, critères et prochaines étapes est dans [MVP](docs/MVP.md). Les anciennes références Lovable se consultent depuis [DESIGN](docs/DESIGN.md).

## Lancer sur iOS

Prévoir macOS, Xcode et un simulateur iPhone, ainsi qu’un SDK Flutter compatible avec la contrainte Dart `^3.13.5` de `pubspec.yaml`. Les anciennes validations mentionnaient Flutter 3.47.7 / Dart 3.13.5 ; ce n’est pas une vérification du SDK installé aujourd’hui.

Depuis le dépôt local :

```sh
cd ~/Dev/APP/thought_inbox
flutter pub get
flutter devices
flutter run -d <identifiant-du-simulateur-iPhone>
```

Pour une nouvelle copie : cloner `https://github.com/BertrandM78/thought-inbox.git`, puis lancer ces commandes depuis la racine clonée. Pour ouvrir le projet iOS : `open ios/Runner.xcworkspace`.

## Vérifier un changement de code

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Un parcours sur iPhone/simulateur, incluant fermeture complète et relancement, complète les contrôles automatiques. Dernier résultat daté dans [MVP](docs/MVP.md).

## Données

Les pensées sont enregistrées dans le conteneur local de l’application en JSON non chiffré par l’app. Aucune sauvegarde ou synchronisation applicative ; la désinstallation peut supprimer les données. Le comportement des sauvegardes système iOS reste à vérifier avant de faire une promesse de confidentialité publique. Ne pas stocker de données personnelles réelles dans les fixtures du dépôt.

## Quatre documents de référence

| Document | Rôle |
| --- | --- |
| [CLAUDE.md](CLAUDE.md) | Règles IA, workflow et architecture réelle |
| [README.md](README.md) | Présentation et lancement |
| [docs/MVP.md](docs/MVP.md) | Produit, périmètre strict, acceptation et livraison |
| [docs/DESIGN.md](docs/DESIGN.md) | Design system, écrans et adaptation Flutter iOS |

Le dépôt GitHub est public par choix de l’utilisateur. Aucune licence open source n’est accordée ; la visibilité publique ne vaut pas autorisation de réutilisation. Les polices Newsreader et Inter Tight sont distribuées sous SIL Open Font License 1.1 ; leurs licences accompagnent les fichiers dans `assets/fonts/` et sont enregistrées dans l’app.
