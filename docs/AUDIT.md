# Inspection préalable — 21 octobre 2026

## Source inspectée

Projet local : `~/Dev/APP/thought_inbox`. Dépôt : `BertrandM78/thought-inbox`, branche locale à vérifier avant le prochain travail. HEAD inspecté : `9bc24a50aceb272ee199f105064666d86b69d585`, correspondant à la tête GitHub observée lors de l’inspection. Le dossier de cette conversation était vide de code ; le projet existant a été retrouvé à partir du suivi précédent.

Lecture effectuée avant modification : README, CLAUDE, tous les fichiers Dart de `lib/`, `pubspec.yaml`, statut/diff Git, MILESTONE-1, PRODUCT, FIRST-PROMPT et SECURITY-REVIEW. Les noms des tests et le parcours des tests widgets ont aussi été examinés. Aucune instruction AGENTS.md trouvée dans la chaîne de dossiers du projet ou sous `~/Dev/APP` lors de l’inspection.

## Travail préexistant à préserver

Quatre fichiers étaient déjà modifiés dans l’index :

- `lib/main.dart` : démarrage asynchrone du stockage.
- `lib/storage/thought_storage.dart` : emplacement obtenu via `path_provider`.
- `pubspec.yaml` : ajout de `path_provider: ^2.1.6`.
- `pubspec.lock` : résolution correspondante.

Ces modifications ne sont pas attribuées à cette tâche et ne doivent être ni réinitialisées ni indexées/committées avec les documents sans instruction. Aucun code Dart, dépendance, test ou paramètre Xcode n’est modifié par le cadrage documentaire.

## Ce qui existe

- Modèle `Thought`, sérialisation et contrôle de format.
- `ThoughtInboxController` : `ChangeNotifier`, injection stockage/horloge/identifiants, tri décroissant, écritures sérialisées et mutation après sauvegarde.
- `ThoughtStorage` injectable, fichier JSON version 1, écriture temporaire puis renommage et erreurs explicites.
- Une page Material avec compositeur et liste Inbox, navigation inférieure Inbox/Archives, états vides, chargement et erreurs.
- Tests modèle, stockage fichier, contrôleur et widgets. Le statut historique rapporte 27 réussites le 20 octobre ; ils n’ont pas été relancés pour cette tâche de documentation.

## Écarts à Lovable

| Existant | Cible montrée |
| --- | --- |
| Compositeur et liste sur la même page | Capture et À traiter séparés |
| Barre inférieure Inbox/Archives | Accès inbox en haut ; retour Capturer |
| Thème dérivé d’une graine lavande, clair/sombre | Palette chaude claire explicite |
| Typographie Material implicite | Serif éditoriale + sans serif |
| Champ encadré, bouton avec icône | Champ nu, bouton pilule |
| Dates absolues | Dates relatives |
| Action Archiver visible | Cercle + menu ; comportement à préciser |
| Pas de suggestions | Trois pastilles de démonstration, intégrations non spécifiées |

L’architecture reste adaptée ; une refonte de l’UI suffit pour M2/M3. Le stockage et ses tests ne doivent pas être réécrits à cette occasion.

## Références récupérées

Les deux images jointes à la conversation APP ont été ouvertes et examinées : Capture (860 × 1670 px) et À traiter (852 × 1668 px). La deuxième portait le nom trompeur `Page2-Archive.png` ; sa copie de référence est nommée `inbox-populated.png`. Aucun export de code Lovable n’a été fourni.

## Limites de vérification

Pas d’exécution Flutter, d’essai sur simulateur, de test de migration de stockage ni de validation visuelle de l’application dans ce jalon. Aucun commit ni push demandé. La comparaison GitHub est une observation ponctuelle ; recontrôler le statut et les différences avant le prochain développement.

Le changement de chemin de stockage et les libellés Material constituent les deux points à distinguer : le premier demande une validation de données sur iOS ; les seconds relèvent du travail visuel à venir.

## Audit de structuration — seconde passe (21 octobre 2026)

Objet : contrôler la documentation existante et l’état Git avant publication. Aucun code Dart modifié, aucun nouveau fichier Dart, aucun commit, aucun push. Sauvegarde des états précédents des documents : `.git/pre-audit-2026-10-21/` (invisible à Git).

### État Git

- Dépôt effectif : `thought_inbox/.git`, branche `main`, remote `origin` = `https://github.com/BertrandM78/thought-inbox.git`. HEAD `9bc24a5` (« feat: build Thought Inbox first milestone and public project docs »), précédé de `faa3dfd` (« chore: initialize Flutter application »). 63 fichiers suivis.
- Indexé, non commité : `lib/main.dart`, `lib/storage/thought_storage.dart`, `pubspec.yaml`, `pubspec.lock` (travail `path_provider`). Préservé.
- Modifiés, non indexés : `CLAUDE.md`, `README.md`, `docs/FIRST-PROMPT.md`, `docs/MILESTONE-1.md`, `docs/PRODUCT.md`.
- Non suivis : `docs/ARCHITECTURE.md`, `docs/AUDIT.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`, `docs/design/`.
- Dépôt parent `~/Dev/APP/.git` : aucun commit, aucun remote, `thought_inbox/` non suivi. Source de confusion (décision D10).
- La tête distante n’a pas été comparée : aucun accès GitHub vérifié. Le HEAD local est la seule référence contrôlée.

### Contrôles sensibles

- Motifs de secrets (clés AWS, clés privées PEM, clés Google API, mots « secret », « password », « api key ») : aucun identifiant trouvé. Les occurrences relevées sont du texte de documentation. Gitleaks n’a pas été rejoué.
- Fichiers ignorés vérifiés avec `git check-ignore` : `ios/Flutter/ephemeral/flutter_native_integration.env`, `.idea/`, `thought_inbox.iml`, `ios/Flutter/Generated.xcconfig`, `.flutter-plugins-dependencies`. Aucun n’est suivi. Le fichier `.env` n’a pas été ouvert.
- Aucun fichier suivi ne correspond à `.env`, clé, certificat, profil de signature, `GoogleService-Info.plist` ou `xcuserdata`.

### Vérification des affirmations

| Affirmation | Résultat |
| --- | --- |
| 27 tests | 27 déclarations trouvées (controller 11, file_storage 5, thought 2, widget 9). Non exécutés : Flutter absent de l’environnement d’inspection. |
| Stockage via `path_provider` | Confirmé (`getApplicationSupportDirectory`). |
| Onglets Material en bas | Confirmé (`home_page.dart`, `NavigationBar`). |
| Thème sombre existant | Confirmé (`app.dart`, `darkTheme`, graine lavande). |
| Dépôt vide désactivé | Non confirmé : le bouton reste actif et un message s’affiche. Écart. |
| Chemin de stockage | Ancien : `…/Application Support/thought_inbox/thoughts.json`. Actuel : `…/Application Support/thoughts.json`. Aucune migration. Risque D3. |
| Captures de référence | Ouvertes le 21 octobre. Description conforme, sauf le menu « … » corrigé : il est à droite de chaque carte. Aucune couleur mesurée. |

### Écarts code / cible

1. Un écran avec onglets Material (code) / deux écrans sans barre de navigation (cible).
2. Dépôt vide : bouton actif et message (code) / bouton désactivé (cible).
3. Pas de cercle d’action sur les cartes (code) / cercle Archiver (cible, D4).
4. Chemin de stockage modifié sans migration (code) / données préservées (exigence). Voir D3.
5. Thème lavande généré par Material (code) / palette chaude de référence (cible).
6. Pas de pastilles de suggestion (code) / pastilles de démonstration (cible).

### Non vérifié

- État réel de GitHub.
- `flutter analyze`, `flutter test` sur l’arbre courant.
- Simulateur iOS et redémarrage complet de l’application.

### Prochaine tâche concrète

M1 : relancer formatage, analyse et tests sur l’arbre courant, puis vérifier sur simulateur iOS si des données existent sous l’ancien chemin (D3). Aucun développement de nouvelle fonctionnalité avant cette clôture.

## Contrôles complémentaires — troisième passe (21 octobre 2026)

Objet : vérifier la documentation contre le code et l'état Git avant toute publication. Aucun code Dart modifié, aucun commit, aucun push.

- **Git** (`thought_inbox/`) : HEAD `9bc24a5`, branche `main`, suivi `origin/main`. État identique à la passe précédente : 4 fichiers indexés, 5 modifiés, 5 entrées non suivies (dont `docs/design/`). Le remote n'a pas été interrogé.
- **Dépôt parent** `~/Dev/APP/.git` : toujours sans commit.
- **Secrets** : aucun motif trouvé (clés AWS, clés privées PEM, clés Google, `password`, `secret`, `api key`, `token`, `bearer`) dans les fichiers suivis et les nouveaux fichiers.
- **Fichiers sensibles suivis** (`.env*`, clés, profils de signature, `GoogleService-Info.plist`, `google-services.json`, `xcuserdata`, `.idea`, `*.iml`, `ephemeral`, `Generated.xcconfig`) : aucun.
- **Présents mais ignorés** : `.dart_tool/`, `.idea/`, `build/`, `ios/Flutter/ephemeral/`, `Generated.xcconfig`, `flutter_export_environment.sh`, `GeneratedPluginRegistrant.*`, `.flutter-plugins-dependencies`, `thought_inbox.iml`.
- **Identifiants publics** : bundle `com.bertrandm78.thoughtInbox` (et `.RunnerTests`) dans `ios/Runner.xcodeproj/project.pbxproj`. Aucun `DEVELOPMENT_TEAM` trouvé. Non secrets, mais visibles sur un dépôt public.
- **Captures** : dimensions conformes (860 × 1670 et 852 × 1668). Aucun champ auteur, logiciel ni chemin trouvé dans les métadonnées.
- **Stockage** : diff confirmé. Ancien chemin `$HOME/Library/Application Support/thought_inbox/thoughts.json` ; nouveau `getApplicationSupportDirectory()/thoughts.json`. Modification non commitée. Décision D3 toujours ouverte.
- **Tests** : 27 déclarations confirmées (contrôleur 11, stockage fichier 5, modèle 2, widgets 9). **Non exécutés** : aucun SDK Flutter accessible depuis le shell du Mac, ni en shell non interactif ni en shell de connexion. Cette passe ne valide donc aucun test.
- **Couleurs** : relevées dans les PNG (pixels les plus fréquents), voir DESIGN.md, « Tokens provisoires ».

