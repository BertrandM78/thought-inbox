# Thought Inbox — règles de travail

## Avant de modifier

1. Lire `README.md`, `docs/PRODUCT.md`, `docs/DESIGN.md`, `docs/ARCHITECTURE.md` et le jalon concerné dans `docs/ROADMAP.md`.
2. Examiner `git status --short`, les différences indexées et non indexées et les fichiers concernés. Préserver les modifications préexistantes ; ne jamais les réinitialiser ni les inclure dans un commit par défaut.
3. Pour une tâche visuelle, ouvrir réellement les deux PNG de `docs/design/reference/` et lire leur manifeste. Le texte seul ne suffit pas.
4. Annoncer le périmètre du jalon, les fichiers envisagés et la validation prévue, puis exécuter le travail autorisé.

## Produit et design

- Interface française, iOS en premier. Capture sans titre ni tri imposé ; liste « À traiter » ; archivage réversible.
- Reproduire la composition Lovable : fond chaud, textes serif, métadonnées sans serif, cartes blanches arrondies et accent violet. Ne pas appliquer un style Material générique ni ajouter une barre d’onglets aux deux écrans de référence.
- Ne pas inventer une police exacte, une mesure logique ou un état absent des captures. Documenter les estimations et décisions ouvertes dans DESIGN.md.
- Pas de refonte esthétique, changement de palette, nouvel écran, nouvelle dépendance ou intégration externe hors du jalon demandé. Demander une décision seulement si elle bloque réellement le travail ou modifie le périmètre autorisé.
- Les pastilles de suggestions des références ne prouvent pas l’existence d’une IA ou d’intégrations. Les réserver au prototype visuel tant que leur comportement n’est pas défini.
- Conserver les archives et la restauration ; proposer leur point d’accès sans encombrer Capture.

## Code et données

- Garder modèle, stockage injectable, contrôleur `ChangeNotifier` et widgets séparés. Injection par constructeur, navigation Flutter native ; pas de couche métier supplémentaire sans besoin démontré.
- Extraire les composants réutilisés et les tokens au moment de leur utilisation, sans arborescence vide ni réécriture du contrôleur.
- Attendre les écritures avant succès ; préserver saisie et état lors d’un échec ; ne pas écraser un fichier illisible. Conserver identifiants et schéma JSON lors du travail visuel.
- Ne pas modifier les changements `path_provider` existants sans tâche explicite. Vérifier la compatibilité avec les données déjà présentes avant toute évolution de stockage.
- Pas de compte, backend, IA, synchronisation, télémétrie ou notifications dans ces jalons.
- Ne pas lire/copier/committer de secrets ou données personnelles ; ne pas modifier signatures, comptes ou identifiants Apple.
- Ne créer aucun commit, push, publication ou changement de visibilité sans demande explicite pour la session.

## Validation et compte rendu

- Code : formatage, `flutter analyze`, `flutter test`. Adapter les tests UI quand le parcours évolue ; conserver les tests de modèle, de stockage et du contrôleur.
- Visuel : captures des deux écrans avec les mêmes cinq exemples, comparaison manuelle, contrôle du clavier, du défilement, du texte agrandi et des libellés accessibles. Voir DESIGN.md.
- Ne jamais régénérer des goldens pour accepter automatiquement une régression.
- Mettre à jour ROADMAP.md et le statut utile ; distinguer « implémenté », « vérifié automatiquement » et « validé sur iOS/visuellement ». Rapporter les contrôles réellement exécutés et les blocages.
- Terminer par le résultat, les fichiers concernés, les vérifications et le prochain point non validé. Une référence approuvée ne signifie pas que sa reproduction Flutter est validée.

## Dépôt et références

- Le dépôt Git est `thought_inbox/` (remote `origin` : `BertrandM78/thought-inbox`). Lancer `git` depuis ce dossier.
- `~/Dev/APP` contient un autre `.git`, sans commit ni remote, qui voit `thought_inbox/` comme non suivi. Ne pas l’utiliser pour committer (décision D10).
- Les captures de référence sont dans `docs/design/reference/`. Il n’existe pas de dossier `lovable/`.
- `README.md` est rédigé en anglais. Les autres documents et ce fichier restent en français.
- Les modifications déjà indexées (`lib/main.dart`, `lib/storage/thought_storage.dart`, `pubspec.yaml`, `pubspec.lock`, travail `path_provider`) ne sont jamais incluses dans un commit de documentation sans demande explicite.
- Ne jamais lire ni publier les fichiers ignorés : `.env*`, `ios/Flutter/ephemeral/`, `Generated.xcconfig`, `.idea/`, `*.iml`, `build/`, `.dart_tool/`.
