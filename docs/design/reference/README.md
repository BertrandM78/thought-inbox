# Références Lovable — originales

Ces copies conservent les octets des deux pièces jointes de la conversation APP, récupérées le 21 octobre 2026. Ne pas les retoucher ni les remplacer par le rendu Flutter. Toute nouvelle direction visuelle reçoit un nouveau fichier et une décision explicite.

| Écran | Fichier de référence | Nom d’origine | Dimensions |
| --- | --- | --- | --- |
| Capture, champ vide, badge 5 | [capture-empty.png](capture-empty.png) | Page1-Accueil-Inbox.png | 860 × 1670 px |
| À traiter, cinq pensées | [inbox-populated.png](inbox-populated.png) | Page2-Archive.png | 852 × 1668 px |

Le second écran représente l’inbox active, pas les archives. Noms en minuscules, ASCII et tirets pour garder des chemins stables. Ces fichiers documentaires ne sont pas des assets à embarquer dans l’app ; aucune déclaration dans `pubspec.yaml` n’est nécessaire.

## Fixture de comparaison

Conserver l’ordre ci-dessous pour comparer le rendu. Cet ordre reproduit la maquette et ne remplace pas le tri chronologique de production. Les temps sont figés pour la démonstration ; les identifiants de test peuvent être `reference-1` à `reference-5`.

| # | Texte | Pastille | Temps affiché |
| --- | --- | --- | --- |
| 1 | Appeler Michel demain pour le déménagement | Appeler · Téléphone ↗ | il y a 25 min |
| 2 | Acheter du lait et des citrons | Rappel · Rappels ↗ | il y a 3 h |
| 3 | Rechercher les dates du TOEFL | Rechercher · Recherche Web ↗ | hier |
| 4 | Idée de projet étudiant : une carte des bibliothèques calmes | aucune | il y a 1 h |
| 5 | Le silence entre deux notes, c’est aussi de la musique | aucune | il y a 2 j |

Capture : « Plus tard », « CAPTUREZ MAINTENANT », « Qu’avez-vous en tête ? », « Pas de titre, pas de tri. », « Déposer », « Traitez plus tard, l’esprit libre. » et badge 5. Liste : retour « Capturer », titre « À traiter », compteur « 5 en attente ».

## Ce que les images ne spécifient pas

Polices exactes/licences, taille logique et ratio de pixels, état clavier, dépôt actif, erreurs, archives, menus ouverts, ordre de production, comportement du cercle et intégrations. Voir [DESIGN.md](../../DESIGN.md) et [PRODUCT.md](../../PRODUCT.md) pour les propositions et validations.

Les futurs rendus de l’app iront dans `docs/design/validation/` seulement quand ils auront été produits, avec leur appareil, viewport, date et statut de revue.
