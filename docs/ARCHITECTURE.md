# Thought Inbox — architecture Flutter légère

## Décision

Conserver l’architecture actuelle : modèle, stockage, contrôleur, interface. Elle répond déjà au petit périmètre. Séparer les deux écrans et centraliser les styles lors du travail visuel ; pas de migration vers une architecture à multiples couches, ni de gestionnaire d’état supplémentaire.

## Existant inspecté

```text
lib/
  main.dart                         # initialise Flutter et le stockage
  app.dart                          # MaterialApp, thème, page initiale
  models/thought.dart               # modèle immuable, JSON versionné côté stockage
  storage/thought_storage.dart      # interface + stockage fichier + exceptions
  state/thought_inbox_controller.dart # ChangeNotifier, tri et mutations sérialisées
  ui/
    home_page.dart                  # composition, listes et archives dans une page
    date_format.dart               # date absolue française
```

Le stockage local en cours utilise `path_provider` et un démarrage asynchrone. Ces modifications préexistent à cette documentation. Les tests injectent un stockage mémoire et une horloge ; conserver ces points d’injection.

## Structure cible progressive

Les chemins ci-dessous sont une cible, pas des fichiers déjà créés. Chaque extraction intervient dans le jalon qui l’utilise.

```text
lib/
  main.dart
  app.dart
  models/thought.dart
  storage/thought_storage.dart
  state/thought_inbox_controller.dart
  ui/
    theme/
      app_colors.dart
      app_typography.dart
      app_spacing.dart
      app_theme.dart
    capture/capture_page.dart
    inbox/inbox_page.dart
    archive/archive_page.dart
    widgets/thought_card.dart
    widgets/inbox_button.dart
    widgets/load_state.dart
    date_format.dart
```

`home_page.dart` assure temporairement la transition puis est retiré quand la navigation et ses tests sont remplacés. Extraire un widget partagé seulement quand il clarifie une responsabilité ou sert plusieurs écrans. Les états vides peuvent rester locaux. Une pastille dédiée ne devient un composant que pendant le prototype qui l’emploie.

## Responsabilités et flux

```text
Widget → ThoughtInboxController → ThoughtStorage → fichier JSON
         ChangeNotifier → reconstruction des widgets
```

- `main.dart` : obtenir le répertoire natif, injecter le stockage et démarrer le chargement. Aucune décision de design.
- `app.dart` : configuration d’application, thème, navigation initiale et propriété du contrôleur partagé.
- Contrôleur : unique source des pensées, compteurs dérivés de `inbox.length`, règles de capture/archivage/restauration, sérialisation des écritures. Aucun accès à `BuildContext`.
- Stockage : lecture/écriture, version du format, erreurs explicites. Pas de texte UI ni de navigation.
- Écrans : écoute via `ListenableBuilder`, affichage des états et appel du contrôleur. Le brouillon appartient à l’état de Capture, conservé pendant l’aller-retour ; libérer son `TextEditingController` dans `dispose`.
- Propriétaire du contrôleur : le créer une seule fois et définir sa libération selon sa durée de vie. Ne pas le recréer dans `build` ou à chaque navigation.

Navigation : `Navigator` et `MaterialPageRoute` suffisent pour Capture → À traiter → Archives, avec le même contrôleur passé par constructeur. Conserver Capture montée sous la route suivante. Aucun besoin actuel de liens profonds ni d’un routeur externe.

## Thème et adaptation

Centraliser couleurs, typographies, rayons et espacements. Composer avec `SafeArea`, contraintes et défilement ; éviter positions absolues et mise à l’échelle globale depuis les pixels des PNG. Le clavier réduit l’espace disponible sans cacher le dépôt. Le fond beige et la typographie explicite doivent remplacer les valeurs implicites du thème dans les écrans refaits.

La configuration sombre existante est un écart à examiner, pas à supprimer automatiquement. M2 vise la référence claire ; la décision sur le mode système précède M4.

## Données et compatibilité

Aucune modification du schéma v1 pendant M2/M3. Conserver les dates UTC sérialisées et l’affichage local. Les dates relatives restent une fonction de présentation avec une horloge injectable, sans modifier `createdAt`.

Le stockage lit désormais `getApplicationSupportDirectory()/thoughts.json`. Si ce fichier est absent, il relit l’ancien chemin `Application Support/thought_inbox/thoughts.json`, valide son format v1 puis copie les données vers le nouveau chemin par écriture temporaire et renommage. La source historique reste intacte ; une erreur de migration est exposée et ne produit pas une liste vide. Cette migration doit encore être vérifiée sur simulateur iOS avec des données existantes avant la validation complète de M1.

## Tests proportionnés

- Conserver modèle/contrôleur/stockage et leurs cas d’erreur.
- Adapter les tests widgets aux routes, au compteur, au brouillon et aux états d’écriture ; ne pas masquer les anciennes assertions devenues invalides.
- Dates relatives : tester les seuils et changements de jour avec horloge fixe.
- Goldens facultatifs après stabilisation des polices et validation humaine des captures Flutter. Les PNG Lovable servent à la comparaison visuelle, pas de goldens Flutter directement exécutables.
- Le test mémoire ne remplace pas le contrôle du plugin natif et du relancement sur iOS.

## Conventions

- Identifiants, fichiers et types en anglais ; textes d’interface et commentaires en français, comme dans le code actuel.
- Une responsabilité par fichier. Pas de fichier, dossier ni classe vide : un dossier naît avec son premier fichier.
- Aucune nouvelle dépendance sans besoin présent. Dépendances actuelles : `path_provider` et `cupertino_icons`.
- Dépendances injectées par constructeur ; état partagé uniquement via `ChangeNotifier`.
- Valeurs visuelles dans des tokens dès qu’elles sont réutilisées. Les données de démonstration restent dans une fixture dédiée, jamais dans le stockage de production.
- Commandes Git lancées depuis `thought_inbox/`, qui est le dépôt du projet (voir D10).

## Quand faire évoluer

Ajouter une couche ou une dépendance seulement pour un besoin présent : migrations complexes, plusieurs sources de données ou navigation réellement plus riche. Documenter alors le problème et le coût avant la modification. Le nombre de dossiers ne constitue pas un critère de qualité.
