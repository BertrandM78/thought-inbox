# Thought Inbox — contrat visuel

## Sources et hiérarchie

Les deux PNG de [design/reference](design/reference/README.md) sont la référence pour les états qu’ils montrent. Le code Lovable, les polices, le viewport CSS et le ratio de pixels n’ont pas été fournis. Les valeurs numériques ci-dessous sont des points de départ à calibrer ; aucune identité exacte de police ne peut être déduite d’une capture seule.

En cas de conflit : préserver la composition des références pour les états illustrés, respecter les comportements de PRODUCT.md et la conservation des données. Pour un état absent, prolonger les mêmes styles, documenter la proposition et la présenter au propriétaire avant de la considérer validée.

## Avis sur le design

Direction cohérente avec un outil de capture calme : une seule action principale, peu de chrome et une hiérarchie éditoriale identifiable. À conserver. Le rendu de l’application n’est pas encore validé : le contraste de l’invitation et des petits textes, les zones tactiles, les longues pastilles et le clavier nécessitent des vérifications réelles. Ne pas augmenter la densité pour remplir les espaces de Capture.

## Capture — invariants

- Fond blanc cassé chaud ; signature serif italique « Plus tard » en haut à gauche.
- Icône inbox en haut à droite et badge violet superposé avec « 5 » dans l’exemple.
- Grand espace avant « CAPTUREZ MAINTENANT », libellé sans serif gris.
- Invitation serif « Qu’avez-vous en tête ? », grande et très claire ; champ sans cadre apparent.
- Aide à gauche, bouton pilule « Déposer » à droite ; bouton gris inactif dans cet état vide.
- Pied de page centré près du bas : « Traitez plus tard, l’esprit libre. ».
- Aucune barre de navigation inférieure sur cet écran de référence.

La forme extérieure arrondie et le fond gris aux coins semblent appartenir au cadre de capture. Ne pas dessiner un téléphone ou arrondir la racine de l’application pour les imiter ; vérifier le rendu dans la zone sûre iOS.

## À traiter — invariants

- Retour violet « Capturer », titre serif noir dominant et compteur gris aligné à droite.
- Cinq cartes blanches, coins très arrondis et ombre discrète, séparées par un espace régulier.
- Cercle fin à gauche, texte serif à droite, menu « … » à droite de chaque carte, aligné sur la première ligne du texte.
- Métadonnées sans serif grises sous le texte ; pastille lavande et flèche diagonale pour les trois premiers exemples.
- Alignement constant du texte et des métadonnées ; pas de pastille pour les deux dernières pensées.
- Liste défilante ; ne pas réduire la typographie pour forcer cinq cartes sur tous les appareils.

## Tokens provisoires

Valeurs mesurées dans les fichiers PNG de référence le 21 octobre 2026 : couleur de pixel la plus fréquente, sans correction de profil colorimétrique ni de rendu d’écran. « Mesuré » = couleur présente dans la capture ; « rôle à confirmer » = la couleur existe, son affectation au rôle est une supposition. À confirmer par l’export Lovable si disponible. Les tailles logiques proposées ne sont pas des mesures extraites des PNG.

| Rôle | Valeur et source |
| --- | --- |
| Fond | `#F9F6F3` — mesuré, fond de la capture |
| Surface carte | `#FEFDFB` — mesuré, surface dominante des cartes ; blanc pur non relevé |
| Texte principal | `#191511` — mesuré, encre la plus sombre fréquente |
| Texte secondaire | `#76706B` — gris mesuré ; rôle à confirmer |
| Texte discret / invitation | `#BEBAB6` — gris mesuré ; rôle à confirmer |
| Accent | `#6C58A6` — mesuré, violet le plus fréquent hors pastille |
| Fond de pastille | `#EBE7FF` — mesuré, pastille lavande de la liste |
| Bouton inactif | `#EEEBE6` — mesuré dans la capture vide ; rôle à confirmer |
| Bord du cercle | `#D6D1D1` — gris mesuré ; rôle à confirmer |
| Échelle d’espaces logique proposée | 4, 8, 12, 16, 24, 32 |
| Marge horizontale proposée | Capture 24 ; liste 16 |
| Rayon proposé | cartes 24 ; boutons/pastilles en pilule |

L’accent mesuré (`#6C58A6`) diffère de la graine lavande du code (`#8E7CC3`, `lib/app.dart`) : ne pas garder cette graine comme référence. Éviter `ColorScheme.fromSeed` seul : il ne garantit pas les fonds, surfaces et contrastes observés.

Typographie : deux familles, une serif éditoriale pour signature, grand titre, invitation et pensées ; une sans serif pour navigation, boutons et métadonnées. Retrouver les noms, graisses et licences dans l’export Lovable si possible. Embarquer les polices retenues localement dans `assets/fonts/` avec leur licence, déclarées dans `pubspec.yaml`. Aucun chargement de police réseau nécessaire.

Points de départ à une largeur logique proche de 390 : titre 36–40, invitation 28–30, pensées 18–20, interface 14–16, métadonnées 12–14. Ajuster selon la vraie police et les retours à la ligne. Ne pas approuver ces chiffres comme une spécification exacte.

## États à compléter

| État absent de la référence | Proposition et contrôle |
| --- | --- |
| Capture remplie | Même composition ; texte principal lisible ; dépôt actif violet, à valider |
| Clavier visible | Réduire l’espace libre, permettre défilement, garder dépôt accessible |
| Enregistrement | Empêcher le double dépôt ; retour discret ; conserver la saisie jusqu’au succès |
| Chargement / erreur | Texte français explicite, Réessayer, sans déplacer durablement la composition |
| Liste vide | Court message et retour Capture, mêmes styles |
| Texte/pastille longs | Retour à la ligne et `Wrap`, aucune hauteur de carte figée |
| Archives | Continuité des cartes ; action Restaurer ; accès à décider en M3 |
| Mode sombre | Aucune référence ; décision explicite avant validation finale |

## Comparer et valider

1. Ouvrir les deux références et reproduire les cinq textes et dates du manifeste dans une fixture isolée, sans les écrire dans le stockage de production.
2. Noter appareil, taille logique, ratio de pixels, taille de texte, polices et état du clavier. Le ratio des PNG ne suffit pas à identifier l’appareil d’origine.
3. Produire deux captures Flutter sans clavier, puis juxtaposer à largeur de contenu identique. Comparer d’abord hiérarchie et espaces, puis typographie/retours, cartes, couleurs, icônes et ombres. Une superposition peut aider après alignement des zones de contenu ; les cadres système sont exclus.
4. Consigner les écarts observés et corrections dans `docs/design/validation/README.md` lorsque les captures existent. Nommer `capture-empty-ios-<largeur-logique>-<date>.png` et `inbox-populated-ios-<largeur-logique>-<date>.png`.
5. Présenter les deux rendus au propriétaire pour validation visuelle avant d’étendre la refonte. Un test vert ne remplace pas cette validation.
6. Contrôler ensuite 320, 390 et 430 points de largeur, petit écran en hauteur, texte ×1, ×1,3 et ×2, longs textes, navigation, clavier et VoiceOver. Aucune coupure d’action ou de pensée.

Viser des zones tactiles d’au moins 44 × 44 points sans grossir nécessairement les icônes visibles. Vérifier les contrastes réels (objectif 4,5:1 pour le texte courant et 3:1 pour le grand texte). Une correction d’accessibilité doit préserver la composition et être présentée comme un écart motivé si elle change les tons de la référence. Les textes d’exemple ne doivent pas être utilisés comme données personnelles réelles.

## Statut

Références récupérées et examinées le 21 octobre 2026. Aucune capture de la refonte Flutter, aucune comparaison iOS et aucune mesure de contraste effectuées dans ce jalon documentaire. Les polices et tokens exacts restent à confirmer.
