# Posé — design system et écrans V1

## Sources, portée et statut

Identité validée : **Posé**, promesse « Libérer l’attention sans perdre les idées », minimalisme éditorial, Newsreader et Inter Tight, thème clair, accent lavande unique. Le nom officiel est **Posé** ; le logotype affiché dans l’app est exactement **« posé. »**, en Newsreader Italic. Le symbole choisi pour la suite est la **plume silhouette pleine**, distincte du logotype. Le thème reste clair même lorsque l’iPhone est en mode sombre.

La source détaillée est [l’extraction Lovable originale](design/reference/lovable/extraction-source.txt), pièce « Texte collé(7).txt » de la conversation APP, récupérée le 24 octobre 2026. Elle décrit `src/styles.css`, `src/routes/__root.tsx`, `src/routes/index.tsx` et `src/lib/thoughts.ts`. Le dépôt web lui-même n’est pas fourni : ses affirmations de conversion « exacte » ne sont pas une vérification indépendante. La pièce complète est conservée sans modification, y compris ses fonctions hors scope et recommandations Flutter ; elle n’est pas une cinquième spécification normative.

Ordre de résolution : décisions utilisateur et [MVP](MVP.md), présent document, extraction pour les propriétés web observées, PNG pour la composition, code Flutter pour l’état réel seulement. Ne pas réintroduire une fonctionnalité parce qu’elle figure dans la source. Les quatre couleurs principales ci-dessous sont explicitement validées ; les autres HEX sont repris de l’extraction, sans recalcul colorimétrique dans cette session.

Deux PNG originaux conservés, ouverts lors de la consolidation :

| État | Fichier | Nom d’origine | Dimensions physiques |
| --- | --- | --- | --- |
| Capture vide, badge 5 | [capture-empty.png](design/reference/capture-empty.png) | Page1-Accueil-Inbox.png | 860 × 1670 px |
| À traiter, cinq pensées | [inbox-populated.png](design/reference/inbox-populated.png) | Page2-Archive.png | 852 × 1668 px |

Le second PNG montre l’inbox active, pas des archives. Ne pas retoucher les originaux ni les embarquer comme assets de production. Leurs dimensions ne donnent ni le viewport CSS ni le ratio de pixels du terminal d’origine. La géométrie ci-dessous provient de l’extraction, pas d’une division arbitraire des pixels des PNG. Aucun rendu Flutter ni contraste n’a été validé par cette session documentaire.

## Symbole et icône iOS

Les fichiers ajoutés dans `assets/branding/` sont les sources choisies pour l’intégration :

| Fichier | Usage |
| --- | --- |
| [pose-feather-silhouette.svg](../assets/branding/pose-feather-silhouette.svg) | Symbole vectoriel seul, fond transparent, aplat #6F57AB |
| [pose-icon-ios-source.svg](../assets/branding/pose-icon-ios-source.svg) | Composition vectorielle carrée, fond plein #F9F6F2 et plume #6F57AB |
| [pose-icon-ios-1024.png](../assets/branding/pose-icon-ios-1024.png) | Export iOS 1024 × 1024 RGB opaque, sans texte ni coins pré-arrondis |
| [pose-feather-silhouette-transparent-1024.png](../assets/branding/pose-feather-silhouette-transparent-1024.png) | Variante transparente du symbole |
| [pose-branding-preview.png](../assets/branding/pose-branding-preview.png) | Aperçu, hors production |

La [notice](../assets/branding/NOTICE.txt) décrit une reconstruction vectorielle manuelle à partir de la planche utilisateur ; elle ne certifie pas une extraction géométrique exacte. Les [contrôles fournis](../assets/branding/CONTROLES.txt) sont des preuves de production antérieures, pas des tests rejoués ici.

Intégré le 24 octobre : `ios/Runner/Assets.xcassets/AppIcon.appiconset` contient une seule entrée universelle 1024, copie exacte (même empreinte SHA-256) de `pose-icon-ios-1024.png` ; Xcode en dérive les tailles, plume vérifiée dans le build simulateur. Le symbole n’est pas utilisé dans l’UI Flutter. Ne pas redessiner le symbole ni le remplacer par un nouveau concept. L’icône iOS passe par le catalogue natif ; une déclaration dans `pubspec.yaml` n’est nécessaire que si une image est effectivement utilisée par l’UI Flutter.

## Palette claire

| Token source | Valeur retenue | Usage V1 / statut |
| --- | --- | --- |
| `background` | **#F9F6F2** | Fond crème validé |
| `card`, `popover` | **#FFFDFB** | Surface ivoire validée, cartes et feuilles |
| `foreground`, `card-foreground`, `popover-foreground` | **#1A1511** | Graphite validé |
| `primary` | **#6F57AB** | Accent lavande unique validé : dépôt, navigation, compteur, curseur |
| `primary-foreground` | #FCFBFF | Texte sur lavande |
| `primary-soft` | #ECE7FF | Nuance lavande ; aucune pastille de suggestion en V1 |
| `secondary`, `muted` | #EEEAE5 | Bouton désactivé et surface secondaire |
| `secondary-foreground` | #322C28 | Texte du bouton secondaire |
| `muted-foreground` | #77706B | Aide, dates, texte discret |
| `border`, `input` | #E1DDD8 | Séparateurs et bordures utiles ; pas de cadre au champ Capture |
| `ring` | #6F57AB à 40 % | Focus si pertinent |
| `destructive` | #D73337 | Couleur sémantique de « Supprimer », pas un deuxième accent décoratif |
| `destructive-foreground` | #FCFCFC | Réservé à une éventuelle surface destructive |

Le token web `success` (#3F9B65) est conservé dans la pièce brute uniquement : adapter le point de succès en lavande ou en neutre pour V1, avec feedback textuel. Ce choix évite d’introduire un deuxième accent. Le rouge reste limité à l’action destructive et ne sert pas au branding.

Opacités web observées : placeholder `muted-foreground` 45 %, aide après dépôt 70 %, pied de page 60 %, texte du bouton désactivé 60 %, cercle non coché 40 %, cercle vide pointillé 30 %, voile de feuille `foreground` 25 % et flou 2 px. Recalculer la composition/contraste sur le fond réel avant adoption : ces opacités peuvent rendre les petits textes trop faibles. Toute correction d’accessibilité est une adaptation motivée, pas une nouvelle palette.

La meta web `theme-color` #F8F5F0 diffère du fond : retenir #F9F6F2 côté app et harmoniser les zones système iOS. Le fond externe `device` #E2DDD7 et toute palette sombre restent hors V1. Ne pas remplacer les couleurs explicites par les seuls résultats de `ColorScheme.fromSeed`.

Les anciens relevés PNG (#F9F6F3, #FEFDFB, #191511, #6C58A6, etc.) et les couleurs locales actuelles ne sont plus la cible. Ils expliquent les écarts de l’implémentation, sans supplanter les valeurs validées.

## Typographie

Deux familles seulement. Newsreader : Regular 400, Medium 500 et Italic 400 ; titres, pensées et signature. La source importe un axe optique `opsz` 6–72 : vérifier son rendu avec les fichiers réellement embarqués. Inter Tight : 400, 500, 600 ; UI, boutons, compteurs et dates. Embarquées le 24 octobre depuis `google/fonts` (fichiers variables `Newsreader[opsz,wght]`, `Newsreader-Italic[opsz,wght]`, `InterTight[wght]`) dans `assets/fonts/` avec leurs OFL ; aucune récupération réseau. Graisse et taille optique (`opsz` = taille, bornée 6–72) sont fixées par `FontVariation` dans `lib/ui/theme/app_theme.dart`.

Valeurs web de l’extraction : tailles/interlignes en px CSS, pas en pixels physiques iPhone. Les hauteurs « centrées » décrivent un conteneur et ne sont pas un interligne de texte.

| Élément | Famille | Taille / graisse | Interligne source | Espacement |
| --- | --- | --- | --- | --- |
| Logotype « posé. » | Newsreader | 18 / 400 italique | ~28, indiqué par défaut | normal |
| Badge compteur | Inter Tight | 11 / 600 | centré dans 18 | chiffres tabulaires |
| Sur-titre Capture | Inter Tight | 13 / 500 | 18 indiqué, hérité à vérifier | 0,025 em, capitales |
| Saisie et placeholder | Newsreader | 30 / 400 | 1,2 = 36 | −0,01 em = −0,3 px |
| Aide et succès | Inter Tight | 14 / 400 | 20 | normal |
| « Déposer » | Inter Tight | 15 / 600 | centré dans 44 | normal |
| Pied de page | Inter Tight | 12 / 400 | 16 | normal |
| Retour « Capturer » | Inter Tight | 16 / 500 | centré dans 44 | normal |
| Titre « À traiter » | Newsreader | 38 / 400 explicite | 1 = 38 | −0,02 em = −0,76 px |
| « X en attente » | Inter Tight | 14 / 400 | 20 | chiffres tabulaires |
| Texte de pensée | Newsreader | 18 / 400 | 1,375 = 24,75 | normal |
| Date relative | Inter Tight | 12 / 400 | 16 | normal |
| Titre état vide | Newsreader | 26 / 400 | 1,25 = 32,5 | normal |
| Message état vide | Inter Tight | 15 / 400 | 20 indiqué | normal |
| Bouton état vide | Inter Tight | 15 / 500 | centré dans 44 | normal |
| Message temporaire | Inter Tight | 15 / 400 | centré dans 56 | normal |
| Aperçu de feuille | Newsreader | 15 / 400 | normal, maximum 2 lignes | normal |
| Actions de feuille | Inter Tight | 17 / 400, 500 pour traiter | centré dans 56 | normal |
| « Fermer » | Inter Tight | 17 / 600 | centré dans 56 | normal |

En Flutter : utiliser les tailles comme point de départ en unités logiques, `height` comme ratio d’interligne et `letterSpacing` en unités logiques après conversion des em. Le rendu dépend des métriques, du strut, du padding des champs et de l’échelle de texte ; un `height` seul ne garantit pas une boîte CSS identique. Ne pas figer une hauteur qui coupe le texte agrandi. Les graisses implicites doivent devenir explicites ; un h1 de 38 px n’implique pas du gras.

## Géométrie et composants

Valeurs numériques ci-dessous attribuées à l’extraction. Le mapping des rayons est **à vérifier** : elle décrit `--radius: 1rem` (16 px), `rounded-lg = 16`, `rounded-xl = 20`, `rounded-2xl = 24` et `rounded-3xl = 28`. Ces correspondances dépendent de la configuration Tailwind réelle, non fournie. Retenir 24 pour les cartes comme cible issue de l’extraction, à calibrer visuellement ; ne pas présenter cette table comme une règle Tailwind universelle. Une pilule doit suivre la moitié de sa hauteur, un cercle sa taille ; pas besoin de recopier 9999 px.

| Composant | Source observée | Adaptation iOS V1 |
| --- | --- | --- |
| Déposer | hauteur 44, padding horizontal 24, pilule, fond lavande ; désactivé fond secondaire / texte discret ; pression scale 0,95 | États du MVP ; cible tactile au moins 44 × 44, pas de dépôt avant sauvegarde |
| Retour Capturer | hauteur 44, padding gauche 4/droite 12, chevron et texte lavande, pression opacité 0,6 | Navigation native, libellé accessible |
| Boîte inbox | 44 × 44, ronde ; marge droite −8 dans le web, pression scale 0,9/fond secondaire | Vérifier alignement dans les marges iOS sans rogner la zone tactile |
| Badge inbox | si nombre > 0 ; haut 6, droite 4 ; hauteur/min-largeur 18, padding horizontal 4 | Compteur réel, largeur flexible pour plusieurs chiffres ; pas de badge 5 fixe |
| Cercle de traitement | visuel 22 × 22, décalage haut 3, bordure 1,5 à 40 % ; disque lavande et coche claire, trait 3,5 arrondi | Zone tactile étendue à 44 × 44 ; action « Marquer traitée », retrait seulement après sauvegarde |
| Champ Capture | fond transparent, sans bordure, quatre lignes de base, curseur lavande | Multiligne et défilable ; Entrée insère une ligne sur iPhone, dépôt explicite par le bouton |
| Carte | ivoire, rayon annoncé 24, padding 16 ; ligne gap 12, cercle, texte extensible, menu visuel 36 × 36 | Hauteur libre, pensée entière consultable, menu tactile 44 × 44 ; aucune suggestion |
| Métadonnées | date sous la pensée ; gap 8 dans la rangée web badge/date | Garder la date et l’alignement du texte ; enlever le badge et son espace réservé |
| Toast | fond graphite, texte crème, côtés 16, bas max(zone sûre, 20), rayon annoncé 24, hauteur source 56 | Hauteur minimale adaptable au texte ; erreurs compréhensibles ; action « Annuler » temporaire après suppression selon MVP |
| Feuille d’actions | côtés 8, bas max(zone sûre, 8), rayon annoncé 24 ; séparateurs 1 ; aperçu centré padding 20/12 ; lignes 56 | « Marquer traitée », « Supprimer », bloc « Fermer » séparé de 8 ; pas d’édition/copie/intégration ajoutée |

Le voile web de feuille utilise 25 % de graphite et un flou de 2 px : point de départ visuel, pas obligation de refaire un composant iOS natif au pixel. Les composants natifs peuvent mieux gérer la zone sûre et l’accessibilité ; documenter les écarts. La source prévoyait des toasts de 5000 ms avec annulation et 2200 ms pour un feedback simple ; le principe d’annulation temporaire après suppression est fixé par les décisions Posé, durée validée : cinq secondes. Les messages d’erreur simples restent 4 s. Le voile de feuille est repris (graphite 25 %) sans le flou de 2 px.

### Ombres

Source CSS claire de carte : deux couches `0 1px 2px oklch(0.2 0.02 60 / 4%)` et `0 8px 24px -12px oklch(0.2 0.02 60 / 10%)`. Conserver l’intention de surface légèrement décollée. Les `BoxShadow` proposés dans la pièce avec graphite #1A1511 sont une approximation : la chroma 0,02 de l’ombre n’est pas celle du token texte (0,012), et CSS/Flutter ne rendent pas forcément le même flou.

Ombre flottante source : `0 20px 50px -20px oklch(0.4 0.1 295 / 35%)`. Le #533E89 suggéré dans la pièce n’a pas été recalculé ici. Ne pas créer un second accent à partir de cette ombre. Le châssis de simulation auquel elle s’applique aussi est hors V1.

## Écran Capture

- Fond crème plein écran iPhone, dans la zone sûre. Source : côtés 24 ; haut max(inset haut, 20), bas max(inset bas, 24). En Flutter, calculer le total voulu plutôt qu’additionner deux fois `SafeArea` et l’inset.
- Header source de hauteur 48 : logotype **« posé. »** en Newsreader Italic à gauche, bouton inbox et compteur à droite. Remplacer « Plus tard » du prototype ; ne pas inventer de symbole de marque.
- Corps aéré, centré dans l’espace disponible. La source ajoute 96 de padding bas pour remonter le corps ; ne pas recopier ce décalage comme compensation universelle du clavier.
- Sur-titre « CAPTUREZ MAINTENANT ». Champ : placeholder « Qu’avez-vous en tête ? », pensée Newsreader 30 ; pas de cadre.
- Ligne d’action source de hauteur 48 : aide à gauche « Pas de titre, pas de tri. » à vide, sinon « X caractères » ; bouton « Déposer » à droite. Adapter la ligne en cas de texte agrandi plutôt que provoquer un débordement.
- Après réussite : « Déposé. Vous y reviendrez. », signal lavande/neutre et compteur mis à jour. Le champ n’est vidé qu’après sauvegarde.
- Pied : « Traitez plus tard, l’esprit libre. ». La promesse produit reste celle du MVP ; ce microtexte issu de la référence ne la remplace pas.
- Clavier : réduire les espaces libres et permettre le défilement pour garder champ et bouton accessibles. Ne pas verrouiller quatre lignes ni la position centrale sur les petits iPhone. L’absence de clavier automatique au lancement reste une recommandation non explicitement validée ; ne pas changer le comportement actuel sans décision.
- Chargement, erreur de lecture, écriture en cours et erreur d’écriture : comportements du MVP, messages en français dans la composition existante, aucun écran d’erreur supplémentaire.

## Écran À traiter

- Même fond et zones sûres. En haut : retour « Capturer », puis titre Newsreader 38 et compteur « X en attente » aligné sur la ligne de base. À texte agrandi, permettre leur réorganisation.
- L’extraction ne donne pas de marge horizontale explicite pour la liste. Le code et l’ancien document utilisent 16 comme point de départ ; **adaptation à valider**, pas une mesure source certifiée.
- Liste verticale, espace entre cartes 10. Source : padding bas 128 pour un toast ; adapter aux messages et insets réels, sans créer un grand vide obligatoire.
- Pensées du plus récent au plus ancien. Cercle = traiter ; menu = traiter/supprimer. Pas d’accès Archives, pas de barre d’onglets, pas de page de détail.
- Dates relatives françaises avec horloge injectable ; vérifier les seuils et les jours locaux. Le code actuel assimile « hier » à une durée de 24–48 h : contrôler ce choix au passage de minuit avant de le présenter comme une date calendaire exacte.
- Zéro pensée : cercle pointillé 64 × 64, « Esprit clair. », « Rien ne vous attend. Profitez du silence. », texte source de largeur maximale 240 ; bouton « Capturer une pensée » secondaire 44. Le centrage web sur 60vh ne devient pas une hauteur Flutter rigide.
- Liste longue ou pensée longue : défilement, cartes de hauteur variable, actions toujours accessibles ; ne pas réduire les caractères pour faire entrer cinq cartes.

## Interactions et animations

Les valeurs suivantes décrivent Framer Motion dans la source, pas des durées de navigation Flutter validées :

| Effet source | Paramètres rapportés | Statut Flutter V1 |
| --- | --- | --- |
| Navigation / feuilles | stiffness 380, damping 34 | Référence de sensation ; transitions natives acceptables |
| Badge | stiffness 500, damping 15 | Rebond facultatif après sauvegarde |
| Coche | stiffness 600, damping 20 | Feedback bref facultatif après sauvegarde |
| Pensée qui vole | x +140, y −260, scale 0,2, opacité 0, durée 600 ms, Cubic(0.6, 0, 0.3, 1), pivot haut droit | Finition facultative ; viser la vraie position du compteur, pas des distances fixes |
| Séquence dépôt | vol à 0 ms, badge à 450 ms, remise à zéro à 900 ms | Chronologie de prototype ; ne jamais devancer l’écriture persistante |
| Capture ↔ Inbox | Inbox de droite 100 % → 0 ; Capture vers −30 % et fondu | Adapter à la navigation iOS et à la réduction des animations |

L’extraction propose un ressort Flutter avec ratio 0,87 pour 380/34 et masse 1. C’est une valeur arrondie liée à cette masse ; ne pas confondre `damping` et ratio, ni garantir une équivalence Framer Motion sans comparer le rendu. Les animations ne doivent ni retarder la saisie suivante ni provoquer une perte de données. Respecter la réduction des animations ; aucun effet complexe ne bloque la publication.

Le raccourci web Entrée pour déposer n’est pas repris sur le clavier multiligne iPhone. Le simulateur de téléphone 430 × 860, breakpoint 640, cadre arrondi 48 et démonstrations iPad/desktop ne doivent pas être dessinés dans l’app native. Aucun support iPad dédié n’est promis par cette documentation.

## Références de comparaison et validation

Les PNG originaux contiennent des suggestions, un ancien nom et un ordre de prototype : conserver ces preuves, sans exiger une copie pixel à pixel des éléments exclus. Pour la comparaison V1, employer les mêmes textes sans pastilles, afficher le logotype « posé. » et respecter l’ordre chronologique. Une ancienne fixture de maquette peut rester isolée d’un outil de comparaison, sans être chargée dans la production.

| Ordre original du PNG | Texte | Temps du PNG | Pastille historique hors V1 |
| --- | --- | --- | --- |
| 1 | Appeler Michel demain pour le déménagement | il y a 25 min | Appeler · Téléphone |
| 2 | Acheter du lait et des citrons | il y a 3 h | Rappel · Rappels |
| 3 | Rechercher les dates du TOEFL | hier | Rechercher · Recherche Web |
| 4 | Idée de projet étudiant : une carte des bibliothèques calmes | il y a 1 h | aucune |
| 5 | Le silence entre deux notes, c’est aussi de la musique | il y a 2 j | aucune |

Pour ces âges figés, l’ordre chronologique V1 est **1, 4, 2, 3, 5**. Le tri web qui faisait remonter les suggestions n’est pas repris. Les libellés de suggestions ne justifient ni règles regex, ni dépendances, ni accès aux apps externes.

1. Produire des captures Flutter des deux écrans, horloge/fixture isolées, sans écrire ces exemples en données utilisateur. Noter appareil, largeur/hauteur logiques, ratio, échelle de texte, polices et clavier.
2. Comparer à largeur de contenu identique : hiérarchie, espaces, retours à la ligne, cartes, couleur et ombres ; exclure le cadre et les zones système de la superposition. Annoter les écarts volontaires V1.
3. Vérifier des largeurs de référence 320, 390 et 430 unités logiques selon les simulateurs disponibles, une petite hauteur, texte ×1, ×1,3 et ×2, ainsi que clavier et textes longs. Ce sont des contrôles de layout, pas une liste de modèles iPhone ou versions iOS déjà choisis.
4. Viser des cibles tactiles d’au moins 44 × 44, mesurer le contraste (objectifs 4,5:1 pour texte courant, 3:1 pour grand texte), vérifier VoiceOver : accès À traiter avec compteur, traiter/supprimer sans dépendre d’une icône, ordre de lecture et messages d’erreur.
5. Garder les rendus futurs dans `docs/design/validation/` seulement lorsqu’ils existent, par exemple `capture-empty-ios-390-<date>.png`. Consigner appareil, preuve, limites et validation visuelle dans [MVP](MVP.md), sans créer un nouveau document de référence.

## Points à confirmer pendant l’intégration

Configuration réelle des rayons Tailwind si le code web devient accessible ; rendu des ombres ; choix final des animations (aucune animation spécifique en V1 pour l’instant). Résolu le 24 octobre : polices et licences, annulation 5 s, clavier non ouvert au lancement, marge de liste 16 conservée. Ces points sont des adaptations bornées, pas une invitation à refaire le design. La plume silhouette est intégrée au catalogue AppIcon ; rendu sur appareil réel à vérifier.

### Adaptations appliquées le 24 octobre 2026

- Contraste (mesuré sur #F9F6F2) : `muted-foreground` plein donne 4,52:1 ; à 70 %, 60 % et 45 % il tombe à 2,64, 2,24 et 1,79:1. Les petits textes (aide, pied, dates, compteur) utilisent donc la couleur pleine. Le placeholder Capture et le contour du cercle de traitement passent à 80 % (au lieu de 45 % / 40 %) pour viser 3:1. Ils sont plus foncés que sur les PNG : écart volontaire, à confirmer visuellement.
- Texte du bouton désactivé : `muted-foreground` plein sur `secondary` (4,06:1).
- Badge compteur non agrandi par Dynamic Type (cercle de 18) ; le compteur est annoncé par le libellé VoiceOver du bouton.
- Au-delà de ×1,3, titre « À traiter » et compteur sont empilés. En texte très agrandi avec clavier, « Déposer » est atteint par défilement.
- Icônes : `CupertinoIcons.tray`, `chevron_left`, `ellipsis` ; menu de carte en feuille d’actions maison, pas en menu Material.
- Captures de validation datées : [design/validation](design/validation/), iPhone 17 simulateur, 402 points de large, ×3.

L’ancienne notice technique LaunchImage indiquait que l’écran de lancement se modifie dans `ios/Runner/Assets.xcassets/LaunchImage.imageset`, ou via `ios/Runner.xcworkspace` dans Xcode. Information conservée ici ; la présente mise à jour documentaire ne modifie aucun asset. L’icône d’app utilise le catalogue AppIcon distinct de LaunchImage.
