# Thought Inbox — vision produit

## Intention

Déposer une pensée quand elle arrive, libérer son attention et la retrouver plus tard. L’inbox accueille les idées sans demander de décider immédiatement de leur destination. Cette base et le premier jalon ont été validés le 20 octobre 2026 ; les échanges plus anciens disponibles ne contiennent pas de spécification détaillée exploitable.

## Public et usage

Pour une personne qui accumule des idées, rappels informels et réflexions au fil de la journée. Exemple : ouvrir l’app, écrire « Explorer cette idée samedi », enregistrer, puis revenir plus tard et archiver la pensée lorsqu’elle n’a plus besoin d’occuper l’inbox.

## Principes d’expérience

- Une action principale évidente : déposer une pensée.
- Aucun titre, tag, dossier ou échéance obligatoire.
- Une interface française, calme et lisible, avec un accent violet lavande.
- Des états vides utiles ; des commandes accessibles avec libellés explicites.
- L’archivage est réversible. Les archives restent consultables.
- Les données restent sur l’appareil pendant ce jalon.

## Milestone 1 — première boucle utilisable

### Comportement attendu

- Saisie multiligne ; refuser une entrée vide ou composée uniquement d’espaces.
- Retirer les espaces de début et de fin à l’enregistrement.
- Enregistrer un identifiant stable, le texte, la date de création et l’état archivé.
- Afficher l’inbox de la pensée la plus récente à la plus ancienne.
- Archiver depuis l’inbox, consulter les archives et restaurer une pensée.
- Restaurer les données au lancement, y compris l’état archivé.
- Attendre l’initialisation du stockage avant d’autoriser les mutations.
- Afficher les erreurs de chargement/écriture sans annoncer un enregistrement réussi ni perdre la saisie. Préserver les données illisibles au lieu de les écraser.

### Critères d’acceptation

1. Une nouvelle installation montre une inbox vide avec une invitation à écrire.
2. Une pensée valide apparaît après enregistrement ; une entrée blanche n’ajoute rien.
3. Deux pensées apparaissent dans l’ordre chronologique décroissant.
4. Archiver déplace la pensée vers les archives ; restaurer la remet dans l’inbox.
5. Relancer l’app conserve les pensées et leur état.
6. Les tests couvrent ces comportements et les erreurs de stockage ; l’analyse statique réussit.
7. Le parcours est vérifié sur simulateur iOS avant de considérer M1 validé de bout en bout.

### Hors périmètre

Suppression définitive, édition, recherche, tags, capture vocale, pièces jointes, notifications, compte, backend, synchronisation, IA et paiement. Android/web ne sont pas encore configurés.

## Limites assumées

La persistance du prototype est locale, non conçue pour protéger des secrets ou des données critiques. Pas de chiffrement applicatif, export, récupération ou garantie de conservation après désinstallation. Une solution de stockage plus robuste pourra être évaluée avant une distribution réelle.

## Suite possible

Après validation du parcours de base : recueillir du retour d’usage, améliorer l’accessibilité, décider de l’édition et de la recherche, puis évaluer les besoins d’export et de sauvegarde. Aucune échéance de livraison n’est fixée.
