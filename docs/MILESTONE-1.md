# Milestone 1 — statut

Spécifié le 20 octobre 2026. Implémenté avec Claude Code, relu et vérifié automatiquement le 20 octobre 2026 : **27 tests passent, analyse statique sans problème, formatage conforme**. Le jalon reste en attente de validation manuelle sur simulateur iOS.

Voir [PRODUCT.md](PRODUCT.md) pour les critères d’acceptation. Ne pas considérer le jalon terminé tant que le statut ci-dessous ne décrit pas les vérifications réellement exécutées.

## Implémenté

- Saisie multiligne « Nouvelle pensée » et bouton « Déposer ». Texte rogné ; entrée vide ou blanche refusée avec un message, sans écriture.
- Chaque pensée : identifiant (horodatage + aléa), texte, date de création, état archivé.
- Inbox triée de la plus récente à la plus ancienne ; onglet « Archives » trié de la même façon. Actions « Archiver » et « Restaurer » avec libellés visibles.
- États vides pour l’inbox et les archives ; état de chargement.
- Persistance locale dans un fichier JSON versionné, `Library/Application Support/thought_inbox/thoughts.json` du conteneur de l’application (chemin obtenu via `HOME`, sans plugin natif). Écriture dans un fichier temporaire puis renommage.
- Chaque modification est enregistrée avant d’être affichée ; les modifications sont sérialisées. Aucune mutation avant la fin du chargement.
- Échec d’écriture : l’état affiché ne change pas, un message s’affiche, la saisie est conservée.
- Échec de lecture (fichier illisible, format inconnu) : message et bouton « Réessayer », dépôt désactivé, fichier existant non modifié.

Code : `lib/models/`, `lib/storage/`, `lib/state/`, `lib/ui/`, `lib/app.dart`, `lib/main.dart`.

## Tests automatisés — 27 réussis

- `test/thought_test.dart` : sérialisation, refus des données mal formées.
- `test/file_storage_test.dart` : absence de fichier, relecture avec état archivé, fichier corrompu préservé, format inconnu, échec d’écriture sans perte du fichier précédent.
- `test/controller_test.dart` : rognage, entrée blanche, ordre, archivage/restauration, relancement, échecs d’écriture et de lecture, mutation avant chargement, mutations simultanées.
- `test/widget_test.dart` : critères d’acceptation 1 à 5 via l’interface, échec d’écriture (saisie conservée), échec d’archivage, échec de chargement puis reprise.

## Vérifications

| Contrôle | Statut |
| --- | --- |
| `dart format lib test` | Réussi ; contrôle final sans modification. |
| Analyse statique : `dart analyze` | Réussie sur tout le projet : `No issues found!`. |
| Tests Flutter : `flutter test` via le lanceur Dart du SDK | Réussis : 27 tests, `All tests passed!`. |
| Parcours sur simulateur iOS (critère 7) | Non exécuté : service CoreSimulator inaccessible dans cette session. |

Environnement : Flutter 3.47.7 / Dart 3.13.5. Les commandes Flutter standard ont rencontré un accès refusé au cache du SDK système. Les dépendances ont été résolues avec `dart pub get --offline`, le formatage et l’analyse avec le binaire Dart du SDK, et les tests avec `flutter_tools.snapshot --no-version-check test --no-pub` depuis une copie de travail du SDK. Le SDK système n’a pas été modifié.

### Dernière validation à effectuer

Depuis le projet, lancer `flutter run` sur un simulateur iOS, puis :

1. Déposer deux pensées ; vérifier que la plus récente apparaît en premier.
2. Archiver une pensée ; vérifier sa présence dans Archives.
3. La restaurer ; vérifier son retour dans l’inbox.
4. Fermer complètement l’app, puis la relancer ; vérifier les textes et les états.
5. Vérifier la saisie avec le clavier et la lisibilité avec une taille de texte agrandie.

## Limites connues

- Stockage non chiffré, non sauvegardé par l’app ; supprimé avec l’application.
- Les menus système Flutter (copier/coller) restent en anglais : les localisations Flutter ne sont pas ajoutées.
- L’emplacement du fichier repose sur la variable `HOME` du conteneur iOS ; à confirmer sur simulateur. Si elle manque, l’app affiche l’erreur de chargement.
- Un fichier illisible bloque le dépôt jusqu’à correction manuelle ; aucune récupération automatique.
