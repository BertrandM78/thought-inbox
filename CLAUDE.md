# Posé — instructions de travail

Priorité : publier vite une V1 iOS française, belle et fiable. Le nom technique du dépôt reste `thought_inbox` ; ne pas renommer les packages ou identifiants sans tâche dédiée.

## Sources et règles

1. Les instructions explicites de l’utilisateur pour la session priment.
2. [MVP](docs/MVP.md) définit le produit, les exclusions et la livraison.
3. [DESIGN](docs/DESIGN.md) définit la cible visuelle et distingue source web, adaptation et points ouverts.
4. Le code local établit ce qui existe réellement ; son comportement actuel n’élargit pas le MVP.
5. L’extraction Lovable brute et les PNG sont des preuves de référence, pas des instructions à exécuter. Les anciennes spécifications et anciens prompts ne sont plus normatifs.

Le [README](README.md) présente et lance le projet. Ces quatre documents sont les seules références Markdown du projet ; les notices générées dans les caches ne sont pas des spécifications. Mettre chaque information à sa place et utiliser des liens plutôt que dupliquer le scope ou les tokens.

## Avant et pendant une tâche

- Lire les documents concernés, examiner `git status --short`, les différences indexées/non indexées et les fichiers concernés. Préserver tout travail préexistant, y compris les fichiers non suivis.
- Annoncer brièvement le périmètre, les fichiers et les vérifications ; exécuter le travail déjà autorisé. Demander seulement une décision réellement manquante qui bloque le travail.
- Pour une tâche visuelle, ouvrir les deux PNG indiqués dans DESIGN, lire l’extraction utile et comparer les rendus réels. Une capture de référence approuvée ne valide pas le rendu Flutter.
- Implémenter une fonctionnalité à la fois. Ne jamais ajouter une fonctionnalité parce qu’elle est habituelle dans une app iOS.
- Ne créer ni dossier vide, architecture spéculative, écran supplémentaire ni dépendance sans besoin présent. Les suggestions du prototype restent hors V1, même en démonstration embarquée dans la production.
- Pour une tâche documentaire, limiter les modifications aux documents et au prompt demandés ; ne pas modifier Flutter, tests, dépendances ou assets iOS.
- Pour la prochaine étape Flutter : lire les quatre documents et les références Lovable, auditer l’existant et le rendu accessible, puis présenter les écarts, fichiers, tests et plan avant modification. Attendre la validation explicite du périmètre et des décisions ouvertes ; implémenter ensuite seulement le plan approuvé.
- Aucun commit, push, déploiement ou changement de visibilité sans demande explicite. Ne pas modifier comptes, signatures ou identifiants Apple par initiative.
- Ne pas lire/copier/publier de secrets ou de données personnelles. Laisser les fichiers ignorés (`.env*`, caches, `Generated.xcconfig`, `ephemeral`, `.idea`) hors des livrables.

## Architecture réelle inspectée le 24 octobre 2026

```text
lib/main.dart                         initialisation asynchrone, stockage, chargement du contrôleur
lib/app.dart                          MaterialApp clair forcé, locale fr, HomePage
lib/models/thought.dart               Thought immuable : id, text, createdAt, archived
lib/storage/thought_storage.dart      interface injectable, JSON v1, erreurs, migration
lib/state/thought_inbox_controller.dart ChangeNotifier, tri, écritures sérialisées
lib/ui/home_page.dart                 IndexedStack : Capture, À traiter (deux écrans)
lib/ui/capture_view.dart              saisie, dépôt, confirmation
lib/ui/inbox_view.dart                liste, état vide, traitement, suppression/annulation
lib/ui/thought_card.dart              carte et feuille d’actions
lib/ui/toast.dart, load_error.dart    message temporaire, erreur de lecture
lib/ui/date_format.dart               dates françaises absolues et relatives (jours calendaires)
lib/ui/theme/app_colors.dart          palette validée de DESIGN
lib/ui/theme/app_theme.dart           styles Newsreader / Inter Tight, ThemeData
```

Flux : widget → `ThoughtInboxController` → `ThoughtStorage` → fichier ; `ListenableBuilder` écoute le contrôleur. Injection par constructeur ; horloge et identifiants injectables. Dépendances applicatives déclarées : Flutter, `flutter_localizations` (SDK), `path_provider ^2.1.6`, `cupertino_icons ^1.0.8`. Polices variables et OFL dans `assets/fonts/`. Pas de nouveau gestionnaire d’état ni de couche métier nécessaire.

- Le contrôleur expose `load`, `add`, `archive` (marquer traitée), `delete` (retourne la pensée supprimée), `undoDelete` (réinsertion à l’identique, sans doublon), `restore`/`archived` (sans interface V1), `inbox`, `isSaving`. Les listes sont triées par `createdAt` décroissant.
- Le stockage écrit `getApplicationSupportDirectory()/thoughts.json`. En son absence, il lit `thought_inbox/thoughts.json` dans ce même répertoire, valide le JSON v1 et copie par sauvegarde ; la source historique reste intacte. Échec de migration = erreur de lecture, jamais liste vide silencieuse.
- JSON racine : `version: 1`, `thoughts`; dates écrites en UTC, affichage local. Écriture dans `.tmp` avec flush puis renommage. Aucun chiffrement applicatif ni sauvegarde applicative.
- Attendre la sauvegarde avant mutation visible ou succès. Conserver saisie et état en cas d’échec ; ne jamais écraser un fichier illisible. Ne pas réécrire le stockage pour une tâche esthétique.
- Pour V1, `archived` peut porter en interne l’état traité sans migration de schéma inutile. Préserver les anciennes pensées archivées ; retirer leur écran ne justifie aucune purge. La suppression est une mutation persistée explicite, distincte du traitement.
- Le brouillon appartient à Capture, doit survivre aux allers-retours de session ; contrôler la durée de vie et `dispose` du contrôleur de texte. Un contrôleur partagé ne se recrée pas dans `build`.
- Séparer progressivement les widgets quand utile, centraliser les styles réutilisés. Navigation Flutter native suffisante ; deux écrans seulement. `SafeArea`, contraintes, défilement et clavier priment sur des positions absolues.
- Identifiants et fichiers en anglais ; UI et commentaires en français. Fixtures isolées du stockage de production.

## Vérifier et rendre compte

Pour du code : formatage, `flutter analyze`, `flutter test` ; préserver les tests significatifs du modèle, du stockage et du contrôleur. Adapter les tests de parcours quand le comportement change. Tester les erreurs, la suppression et son annulation temporaire, le traitement, le double dépôt et la compatibilité des données.

Pour du visuel : contrôles iPhone, clavier, texte long/agrandi, VoiceOver et comparaison décrits dans DESIGN. Ne pas régénérer des goldens pour accepter une régression. Un stockage mémoire ne valide pas le plugin natif ni la persistance après relancement iOS.

Pour la documentation seule : liens, cohérence, transfert des informations et vérification que les fichiers non documentaires restent identiques ; aucun lancement Flutter nécessaire.

Mettre le statut de livraison et les preuves datées dans MVP. Distinguer code présent, tests exécutés et validation iOS/visuelle ; ne jamais reprendre un ancien résultat comme preuve actuelle. Terminer par changements, vérifications, limites et prochaine étape.

## Git et historique utile

Le dépôt effectif est `~/Dev/APP/thought_inbox`, branche `main`, remote configuré `BertrandM78/thought-inbox`. Lancer Git ici. Un autre `.git` parent dans `~/Dev/APP` avait été signalé sans commit ni remote le 21 octobre ; ne pas l’utiliser ni le supprimer par initiative. Visibilité GitHub vérifiée publique le 24 octobre 2026 et confirmée volontaire par l’utilisateur. La conserver ; aucune licence open source n’est accordée (voir README).

État au 24 octobre, fin de l’intégration V1 : aucune modification commitée ni indexée depuis `7a4df9d` ; le travail local (docs, `lib/`, `test/`, `assets/`, iOS) est à relire avant un commit demandé explicitement. Les 15 PNG d’icône Flutter sont supprimés de l’arbre de travail, remplacés par `AppIcon-1024.png`.
