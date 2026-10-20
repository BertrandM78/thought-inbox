# Thought Inbox — contexte de travail

## Sources de vérité

Lire `docs/PRODUCT.md`, `README.md` et `docs/MILESTONE-1.md` avant une modification. La vision et le premier périmètre ont été validés par le propriétaire : capture de pensées, inbox, archivage et persistance locale ; identité violet lavande. Les détails de mise en œuvre restent des choix révisables.

## Principes

- Application Flutter, interface en français, première cible iOS.
- Favoriser une expérience calme : saisie rapide, aucun classement obligatoire.
- Pas de compte, backend, IA, télémétrie ou synchronisation dans M1.
- Garder une architecture proportionnée : modèle, stockage injectable et interface séparés lorsque cela aide les tests. Éviter les frameworks supplémentaires sans besoin concret.
- Ne pas perdre silencieusement les données : attendre les écritures, afficher les erreurs, ne pas écraser un stockage illisible avec une liste vide.
- Ne pas présenter le stockage local comme chiffré ou sauvegardé.
- Ne jamais lire, copier ou committer des secrets ou fichiers personnels. Ne pas modifier les signatures Xcode, comptes ou identifiants Apple.
- Ne pas publier, pousser, changer la visibilité GitHub ou créer un commit sans demande explicite du propriétaire pour cette session.
- Préserver les changements existants et limiter les modifications au jalon demandé.

## Validation

Depuis la racine Flutter : `dart format lib test`, `flutter analyze`, `flutter test`. Ajouter des tests pour la validation des entrées, l’ordre des pensées, l’archivage/restauration, la relecture du stockage et les échecs de stockage. Un test automatique ne remplace pas un essai sur simulateur iOS ; signaler tout contrôle non exécuté.

## Fin de tâche

Mettre à jour le statut dans `docs/MILESTONE-1.md` et le README selon le comportement réel. Résumer les fichiers changés, les contrôles exécutés et leurs résultats, ainsi que les limites. Ne jamais annoncer un test réussi sans l’avoir exécuté.
