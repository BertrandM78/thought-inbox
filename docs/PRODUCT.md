# Thought Inbox — produit

## Intention et périmètre

Déposer une pensée quand elle arrive, libérer son attention, puis y revenir. Pour une personne qui accumule idées, rappels informels et réflexions. Aucune catégorie, échéance ou transformation en tâche n’est requise à la capture.

La base fonctionnelle a été cadrée le 20 octobre 2026. Les deux captures Lovable transmises définissent désormais la direction visuelle à préserver. La refonte ne doit pas supprimer les comportements existants de persistance, d’erreur et de restauration.

## Parcours cible

### Capture

Écran initial avec signature « Plus tard », accès à l’inbox et compteur des pensées actives. Champ multiligne sans bordure, invitation « Qu’avez-vous en tête ? », aide « Pas de titre, pas de tri. », bouton « Déposer » et pied de page « Traitez plus tard, l’esprit libre. ».

- Texte vide/blanc : dépôt désactivé dans le parcours cible ; la validation du contrôleur reste défensive.
- Dépôt valide : rogner les extrémités, conserver les retours internes, attendre l’écriture puis vider seulement le texte effectivement soumis. Rester sur Capture avec retour de succès discret et compteur actualisé.
- Échec : saisie conservée, message explicite et possibilité de réessayer.
- Navigation vers À traiter puis retour : conserver le brouillon pendant la session. Sa conservation après arrêt complet n’est pas promise.
- Chargement : pas de mutation. Échec de lecture : proposer Réessayer sans écraser le fichier.

Ces règles d’interaction complètent l’état statique visible ; elles sont à vérifier pendant le jalon d’intégration.

### À traiter

Retour « Capturer », titre « À traiter », compteur « 1 en attente » / « N en attente », cartes à texte serif et dates relatives françaises. L’ordre de production reste du plus récent au plus ancien. L’ordre des cinq exemples de la capture sert uniquement à comparer le rendu : il n’est pas chronologique.

- Cercle à gauche : proposition de correspondance avec l’action existante Archiver, sans introduire un second état « terminé ». Libellé accessible « Archiver la pensée ». À confirmer avant activation.
- Menu « … » : actions explicites ; périmètre initial limité à Archiver et à un accès aux Archives via un menu de page si retenu. Ni édition ni suppression implicite.
- Archives : conserver consultation/restauration. Leur écran et leur point d’accès ne figurent pas dans les références ; proposition à valider en M3.
- Zéro pensée : état vide bref avec retour à Capture. Compteur calculé depuis le contrôleur, jamais codé en dur.

### Suggestions visibles dans Lovable

Les trois pastilles « Appeler · Téléphone », « Rappel · Rappels », « Rechercher · Recherche Web » sont des éléments du prototype visuel. Leur génération, l’accès aux contacts, les autorisations et les applications cibles ne sont pas spécifiés. En M2 elles figurent uniquement dans les données de démonstration. Aucun bouton de production ne doit simuler une intégration réussie.

## Données existantes

`Thought` : `id`, `text`, `createdAt`, `archived`. Fichier JSON version 1. Ne pas ajouter un titre, un type de suggestion ou un état terminé pour reproduire une image. Garder le modèle et la persistance compatibles pendant la refonte.

## Acceptation du parcours

1. Capturer une pensée sans classement ; refuser une entrée blanche et empêcher un double dépôt pendant l’écriture.
2. Retrouver texte, identifiant et date après relecture du stockage ; ordre décroissant en production.
3. Archiver, consulter les archives et restaurer sans perte de données ; compteurs cohérents.
4. Fermer complètement puis relancer l’app iOS ; vérifier les pensées actives et archivées.
5. Sur erreur de lecture/écriture : ne pas effacer les données ou le brouillon, ne pas afficher de faux succès.
6. Préserver le rendu Lovable sur les deux écrans ; vérifier petits écrans, clavier, texte long, texte agrandi et VoiceOver.

## Hors périmètre actuel

Compte, backend, IA, synchronisation, capture vocale, notifications, monétisation, édition, suppression définitive, recherche et intégrations Téléphone/Rappels/Web. Android et web ne sont pas configurés. Le mode sombre actuel n’a pas de référence Lovable ; sa direction doit être décidée avant validation visuelle de ce mode.

Stockage local non chiffré et sans sauvegarde applicative ; aucune garantie après désinstallation. Les choix ouverts sont consignés dans ROADMAP.md, sans bloquer la préparation visuelle des deux écrans.

## Statut des décisions

Ce qui n’est pas listé sous « Validé » n’est pas une exigence.

### Validé

- Capture sans titre ni classement obligatoire ; liste « À traiter » ; archivage réversible avec restauration.
- Stockage local, sans compte, backend, IA, synchronisation, télémétrie ni notifications.
- Interface en français ; iOS en premier.
- Les deux captures de `docs/design/reference/` constituent la référence visuelle officielle (confirmé le 21 octobre 2026). Leurs valeurs exactes ne sont pas validées.

### Proposé

- Cercle = Archiver (D4) ; accès aux archives par un menu de page (D5) ; menu « … » limité à Archiver.
- Dépôt désactivé pour un texte vide et pendant l’écriture. Le code actuel laisse le bouton actif : écart à fermer en M3.
- Brouillon conservé pendant la session uniquement.
- Suggestions = données de démonstration (D8).

### Ouvert

- Nom affiché (D7), polices exactes (D1), palette exacte (D2), mode sombre (D6), licence (D9).
