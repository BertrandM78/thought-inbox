# Thought Inbox — roadmap MVP

Statut au 21 octobre 2026. Les jalons M0 à M4 constituent le MVP. Chaque jalon se clôt par des preuves datées (commandes exécutées, captures, parcours manuel), pas seulement par du code. Une fonctionnalité n'est « faite » que si sa validation est consignée.

Statuts utilisés : **Fait** (validé avec preuve), **Partiel** (code présent, validation incomplète), **À faire**.

## Vue d'ensemble

| Jalon | Objectif | Statut au 21 octobre |
| --- | --- | --- |
| M0 — Cadrage | Inspection, documentation, règles de travail | Partiel : documents prêts, revue du propriétaire en attente |
| M1 — Base fonctionnelle | Capture, inbox, archives, stockage JSON | Partiel : code présent, tests non relancés sur l'état courant, iOS non validé |
| M2 — Fidélité visuelle | Reproduire les deux écrans de référence | À faire |
| M3 — Parcours intégré | Relier les écrans au contrôleur réel | À faire |
| M4 — Stabilisation iOS | Données, accessibilité, régressions | À faire |

## M0 — Cadrage

**Livrables** : README (anglais), CLAUDE, PRODUCT, DESIGN, ARCHITECTURE, AUDIT, ROADMAP, références PNG dans `docs/design/reference/`.

**Critères de validation**

- [x] Les documents décrivent l'état réel du code (contrôle de l'existant consigné dans AUDIT ; vérifié le 21 octobre contre `lib/` et Git).
- [x] Les décisions validées et les propositions sont distinguées (PRODUCT, section « Statut des décisions »).
- [x] Aucune fonctionnalité prévue n'est présentée comme implémentée (README, « Implemented in code », vérifié contre le code le 21 octobre).
- [x] État Git et fichiers sensibles contrôlés avant toute publication (contrôle du 21 octobre, à refaire juste avant tout commit) ; aucun commit ni push sans accord écrit.
- [ ] Revue du propriétaire.

## M1 — Base fonctionnelle

**Déjà dans le code** : saisie multiligne, rognage, refus du texte vide, inbox triée du plus récent au plus ancien, archivage et restauration, stockage JSON versionné via `path_provider`, états de chargement, vide et erreur. Le détail est dans [MILESTONE-1.md](MILESTONE-1.md).

**Critères de validation**

- [x] Formatage, analyse et tests réussis sur l'arbre courant, y compris les modifications `path_provider` (22 octobre 2026 : 29 tests passants).
- [ ] Sur simulateur iOS : déposer deux pensées, vérifier l'ordre, archiver, consulter les archives, restaurer, fermer complètement l'app, la relancer ; les données sont conservées.
- [x] Migration explicite du chemin historique implémentée et testée ; vérification sur simulateur iOS encore requise.
- [ ] Fichier illisible : message, bouton Réessayer, fichier intact.
- [ ] Échec d'écriture : texte conservé, aucun faux succès affiché.

**Hors M1** : toute refonte visuelle.

## M2 — Fidélité visuelle

**Objectif** : reproduire Capture et À traiter à partir des PNG de référence, sans changer le modèle ni le stockage.

**Critères de validation**

- [ ] Deux écrans Flutter alimentés par une fixture isolée des cinq exemples du manifeste (ordre de la maquette), avec horloge fixe, hors stockage de production.
- [ ] Captures iOS à 390 points consignées dans `docs/design/validation/` avec appareil, viewport, date et polices.
- [ ] Aucun débordement à 320 points.
- [ ] Couleurs, typographies, espaces et rayons centralisés ; aucune valeur visuelle répétée dans les widgets des écrans refaits.
- [ ] Les trois pastilles de suggestion ne simulent aucune intégration réussie.
- [ ] Validation visuelle des deux écrans par le propriétaire.

**Décisions requises** : D1, D2, D5, D7.

## M3 — Parcours intégré

**Objectif** : brancher Capture et À traiter sur le contrôleur et le stockage existants.

**Critères de validation**

- [ ] Le brouillon est conservé lors de Capture → À traiter → Capture pendant la session.
- [ ] Les compteurs proviennent du contrôleur, jamais d'une valeur codée en dur.
- [ ] Le dépôt est désactivé pour un texte vide et pendant l'écriture. Le code actuel laisse le bouton actif et affiche un message : cet écart est à fermer ici.
- [ ] Le succès n'est affiché qu'après écriture réussie.
- [ ] Le cercle archive la pensée, avec le libellé accessible « Archiver la pensée », si la décision D4 est retenue.
- [ ] Les archives sont accessibles, avec restauration, selon la décision D5.
- [ ] Les dates relatives utilisent une horloge injectable ; les seuils sont testés.
- [ ] Tests widgets mis à jour ; tests modèle, stockage et contrôleur conservés.

**Décisions requises** : D4, D5, D8.

## M4 — Stabilisation iOS

**Critères de validation**

- [ ] Installation neuve et données préexistantes testées.
- [ ] Redémarrage réel ; listes vides et longues ; textes longs ; clavier ; appuis répétés sur Déposer sans doublon.
- [ ] Largeurs 320, 390 et 430 points ; texte à ×1, ×1,3 et ×2 ; zones tactiles d'au moins 44 × 44 points.
- [ ] Contrastes mesurés : 4,5:1 pour le texte courant, 3:1 pour le grand texte.
- [ ] VoiceOver : libellés des boutons, cartes et compteur.
- [ ] Mode sombre décidé et documenté (décision D6).
- [ ] Captures de comparaison refaites après intégration.
- [ ] Localisation Flutter française si les menus système doivent être en français.

**Après M4 (hors MVP, non planifié)** : utilisation personnelle pendant quelques jours, puis choix des priorités. L'édition, l'export, la sauvegarde, les suggestions réelles et les intégrations feront chacun l'objet d'un cadrage distinct. Aucune de ces idées n'est une promesse de livraison.

## Décisions

| Id | Sujet | Proposition | Statut | Bloque |
| --- | --- | --- | --- | --- |
| D1 | Polices exactes | Export Lovable si disponible ; sinon une paire locale proche, marquée comme approximation | Ouverte | M2 |
| D2 | Palette | Tokens de DESIGN.md comme point de départ, à mesurer sur les PNG | Ouverte | M2 |
| D3 | Chemin de stockage | Migration du chemin historique vers `getApplicationSupportDirectory()/thoughts.json`, sans changement du format v1 | Implémentée, validation iOS en attente | M1 |
| D4 | Cercle à gauche d'une carte | Archiver, en réutilisant `archived` sans nouvelle notion de tâche terminée | Proposée | M3 |
| D5 | Accès aux archives | Menu de page sur À traiter | Proposée | M2 / M3 |
| D6 | Mode sombre | Référence dédiée, ou mode clair seul jusqu'à nouvelle décision | Ouverte | M4 |
| D7 | Nom affiché | « Plus tard » (signature de la maquette) ou « Thought Inbox » (nom du dépôt) | Ouverte | M2 |
| D8 | Suggestions | Données de démonstration seulement, jusqu'à une spécification | Proposée | M3 |
| D9 | Licence du dépôt | Non choisie | Ouverte | Publication |
| D10 | Organisation Git | Dépôt à la racine `thought_inbox/` ; le `.git` parent de `~/Dev/APP` (sans commit) à retirer ou à ignorer | Ouverte | Publication |

Constat du 21 octobre (diff Git) : le code non commité lit `getApplicationSupportDirectory()/thoughts.json`, alors que la version commitée écrit dans `Application Support/thought_inbox/thoughts.json`. Des données créées avec la version commitée risquent donc de ne pas être lues. Bloquant pour la validation de M1.

## Modèle de bilan par jalon

```text
Jalon / date :
Périmètre livré :
Fichiers modifiés :
Contrôles automatiques exécutés et résultats :
Appareil / viewport / polices :
Scénarios manuels exécutés et résultats :
Captures / écarts visuels :
Validation du propriétaire : en attente / accord daté
Limites et prochain point non validé :
```
