# Posé — MVP iOS

Décisions consolidées le 24 octobre 2026. Ce document remplace les anciens PRODUCT, ROADMAP, AUDIT, MILESTONE-1 et FIRST-PROMPT pour le cadrage produit et le suivi de livraison.

## Vision et objectif

**Posé — Libérer l’attention sans perdre les idées.**

Déposer instantanément une pensée pour retrouver sa concentration, puis la retrouver quand on le souhaite. Productivité personnelle, simplicité et maîtrise de l’attention. Publier au plus vite sur l’App Store avec une belle UI et un stockage fiable ; la qualité du parcours principal prime sur le nombre de fonctions.

## Périmètre définitif

- iOS ≥17 uniquement, interface et messages en français uniquement, une seule identité visuelle claire définie dans [DESIGN](DESIGN.md), conservée même lorsque l’iPhone est en mode sombre.
- Dépôt GitHub public par choix de l’utilisateur, sans licence open source accordée.
- Premier lancement : écran d'accueil unique avant Capture ; aux lancements suivants, Capture est affiché directement.
- Deux écrans principaux : Capture et À traiter. Aucun écran supplémentaire.
- Saisie libre multiligne, sans titre, catégorie, échéance ou classement obligatoire ; bouton « Déposer ».
- Stockage local persistant. Liste des pensées non traitées, du plus récent au plus ancien selon la date de création.
- Consulter le texte et la date, marquer traitée, supprimer, naviguer entre les deux écrans.

## Parcours et fiabilité

### Capture

Ouvrir directement sur Capture, sans ouverture automatique du clavier (comportement conservé, validé le 24 octobre 2026). Déposer un texte non blanc ; rogner les extrémités, préserver les retours internes. Le bouton est désactivé si le texte est blanc, pendant le chargement et pendant l’écriture. Empêcher les doubles dépôts.

Attendre la réussite du stockage avant le feedback, l’actualisation du compteur et l’effacement du texte soumis. Si une nouvelle saisie est autorisée pendant l’attente, ne pas l’effacer avec l’ancien dépôt. La confirmation « Déposé. Vous y reviendrez. » reste visible jusqu’à la frappe suivante, sans minuterie. Un échec garde le brouillon et permet de réessayer. Aller à À traiter puis revenir conserve le brouillon pendant la session ; persistance du brouillon après arrêt complet non promise.

### À traiter

Afficher seulement les pensées non traitées, ordre chronologique décroissant strict, compteur dérivé de la liste. Aucun tri par suggestion. Le texte entier reste consultable sur cet écran par défilement, sans page de détail.

Le cercle d’une carte marque la pensée comme traitée : après sauvegarde réussie, elle quitte la liste et le compteur diminue. Pas d’écran Archives ni de restauration dans la V1. Le booléen existant `archived` peut conserver ce statut en interne ; les données historiques archivées sont préservées. Traiter ne signifie pas supprimer.

Le menu de carte donne accès à « Marquer traitée » et « Supprimer », avec « Fermer ». Supprimer retire explicitement la pensée du stockage après succès ; un échec garde la carte et affiche un message. La suppression est immédiate après écriture réussie, sans confirmation préalable, avec une action « Annuler » disponible temporairement dans un message sur le même écran. Durée validée : cinq secondes. Une nouvelle suppression clôt la fenêtre précédente (la première reste supprimée). Annuler restaure et persiste la pensée avec son identifiant, son texte, sa date et son statut, puis la replace selon le tri courant ; un échec est signalé sans faux succès, avec « Réessayer » pendant la même durée. Après expiration, l’action n’est plus disponible. Aucun écran de corbeille ou d’archives n’est ajouté.

Retour « Capturer » vers le brouillon. État vide explicite avec retour à Capture. Une feuille d’actions ou un message temporaire appartient à l’écran courant, sans créer une nouvelle destination.

### États communs

Chargement : aucune mutation. Échec de lecture/migration : message français et « Réessayer », aucune réinitialisation silencieuse et aucun écrasement du fichier. Échec d’écriture : aucun faux succès, aucune perte du brouillon ou de l’état enregistré. Dates sérialisées en UTC, affichées localement ; horodatage relatif français avec date absolue possible pour les pensées anciennes.

## Exclusions V1

Onboarding, compte, authentification, paywall, abonnement, backend, cloud/synchronisation, traduction ou autre langue, géolocalisation, Android, web/desktop, IA générative, notifications, widgets, personnalisation, thèmes multiples/dark mode et tout écran supplémentaire.

Également exclus : écran Archives/restauration (hors annulation temporaire d’une suppression), édition, recherche, export, capture vocale, suggestions d’actions, moteur contextuel, accès Téléphone/Mail/Calendrier/Rappels/Web/Plans et simulation desktop/iPad. Pas de fausses intégrations ou de suggestions de démonstration dans l’UI de production. Ces idées peuvent être réévaluées après publication ; aucun engagement de version ou de date. L’édition reste hors du périmètre de travail actuel, sans la présenter comme une décision utilisateur historiquement confirmée.

## Critères d’acceptation

- [ ] Installation neuve : écran d’accueil affiché une seule fois, « Commencer » ouvre Capture ; aux lancements suivants, Capture est affiché directement sans onboarding.
- [ ] Installation neuve : Capture immédiatement utilisable, tout le parcours en français, deux écrans et thème clair même avec l’iPhone en mode sombre ; installation sur iOS ≥17.
- [ ] Texte blanc refusé sans écriture ; texte multiligne enregistré une seule fois malgré des appuis rapides ; compteur juste.
- [ ] Capture → Déposer → À traiter : contenu et date corrects, ordre du plus récent au plus ancien, aucun classement contextuel.
- [ ] Fermeture complète et relancement iOS : textes, identifiants, dates et statut traité conservés ; suppression conservée.
- [ ] Traitement et suppression réussis retirent la carte ; leurs échecs conservent l’état et permettent une reprise.
- [ ] Suppression immédiate avec « Annuler » temporaire : restauration fidèle et persistée, expiration selon la durée validée, échecs et suppressions successives vérifiés sans perte.
- [ ] Anciennes données JSON v1 et migration de chemin vérifiées sans perte, anciennes pensées archivées préservées.
- [ ] Lecture impossible : données intactes, dépôt bloqué et reprise proposée. Écriture impossible : brouillon intact, aucun faux succès.
- [ ] Aller-retour entre écrans : brouillon conservé, navigation compréhensible, aucun accès Archives.
- [ ] Deux écrans conformes au design validé, sans suggestions ; texte long, clavier, petites tailles d’iPhone, texte agrandi et VoiceOver vérifiés selon DESIGN.
- [ ] Formatage, analyse et tests significatifs passent sur l’état final ; preuves datées, validation iOS et visuelle distinctes.
- [ ] Nom Posé, icône définitive, configuration iOS/signature, informations de confidentialité et éléments de fiche App Store prêts ; build TestFlight vérifié, puis soumission préparée. Vérifier les exigences de publication en vigueur à ce stade.

## État réel après l’intégration V1 du 24 octobre 2026

| Sujet | Constat local | Travail restant |
| --- | --- | --- |
| Onboarding | Écran d'accueil unique (plume, 3 rangées de fonctionnalités, bouton « Commencer ») ; marqueur fichier `onboarding_done` ; `showOnboarding: false` par défaut dans les tests | Validation sur simulateur et appareil réel à faire |
| Capture / À traiter | Deux vues (`Stack` + `SlideTransition`), brouillon conservé, aucun accès Archives | Geste de retour iOS par balayage non fourni (bouton « Capturer ») |
| Dépôt | Bouton inactif sur blanc, chargement et écriture ; double appui bloqué ; « X caractères » puis « Déposé. Vous y reviendrez. » après sauvegarde | — |
| Traitement | Cercle et feuille d’actions « Marquer traitée » ; `archived=true` conservé, anciennes pensées traitées préservées | — |
| Suppression | `delete` persisté, toast « Annuler » 5 s, échec d’annulation avec « Réessayer » | Fenêtre de 5 s non prolongée sous VoiceOver |
| Identité | « posé. » Newsreader Italic, Newsreader / Inter Tight embarquées (OFL), palette validée | Opacités de texte atténué adaptées pour le contraste (voir DESIGN) |
| Thème / langue | Clair forcé (Flutter et `UIUserInterfaceStyle`), locale et région `fr` | — |
| iOS | Minimum 17.0, nom affiché « Posé », iPhone seul, portrait seul, lancement crème ; bundle et signature inchangés | Signature, équipe, TestFlight |
| Icône | Catalogue AppIcon à entrée unique 1024, copie exacte de `pose-icon-ios-1024.png` ; plume vérifiée dans le build | Rendu sur appareil réel et App Store Connect |
| Suggestions | Supprimées du code | — |
| Données | JSON v1, migration, écritures sérialisées inchangés ; persistance du plugin natif vérifiée sur simulateur | Migration depuis l’ancien chemin non rejouée sur iOS ; appareil réel |
| Tests | 47 tests : modèle, stockage, contrôleur (suppression/annulation), dates, parcours widgets | — |

L’architecture et les garde-fous techniques sont dans [CLAUDE](../CLAUDE.md).

## Roadmap courte

| Jalon | Livrable / condition de sortie | État |
| --- | --- | --- |
| M0 — Cadrage et fondations | Quatre documents cohérents ; tokens/polices intégrés au thème | Fait le 24 octobre |
| M1 — Capture fiable | Saisie, dépôt, erreurs, brouillon et persistance vérifiés sur iOS | Fait sur simulateur ; appareil réel à faire |
| M2 — À traiter | Liste chrono, traitement, suppression, navigation à deux écrans | Fait sur simulateur ; VoiceOver manuel à faire |
| M3 — Finition | UI conforme, animations proportionnées, accessibilité, erreurs et régressions vérifiées | Partiel : UI comparée, animations reportées, VoiceOver et petit écran physique non vérifiés |
| M4 — Publication | Icône, identité iOS, TestFlight vérifié et soumission App Store préparée | Icône et identité iOS intégrées ; signature et TestFlight à faire |

Après chaque jalon, ajouter ici une preuve courte : date, périmètre, commandes/résultats, appareil/viewport, scénarios iOS, captures, validation visuelle et limites. Un jalon n’est pas clos sur la seule présence de code.

## Historique conservé et décisions

- 20 octobre : l’ancien compte rendu déclarait formatage/analyse réussis et 27 tests passants (Flutter 3.47.7, Dart 3.13.5), avec contournement d’un cache SDK inaccessible. CoreSimulator indisponible, aucun parcours iOS validé.
- 21 octobre : audits documentaires et motifs de secrets sans détection rapportée ; aucun test rejoué dans ces audits. Le risque de changement de chemin de stockage a ensuite donné lieu à la migration présente dans le code.
- 22 octobre : les anciens README/ROADMAP rapportaient 29 tests passants après migration. Résultat historique, non reproduit dans cette session ; ne prouve pas les changements Flutter locaux ultérieurs.
- 24 octobre : tous les Markdown du dépôt et le code utile inspectés ; pièce Lovable récupérée et conservée. Liens, consolidation et intégrité des fichiers non documentaires contrôlés ; aucun test Flutter ni essai iOS exécuté.
- 24 octobre, après ajout des logos : audit des quatre Markdown, liens locaux et sources graphiques ; icône iOS Flutter et minimum iOS 15 constatés. Documentation alignée après accord utilisateur ; aucun changement Flutter, test ou asset iOS. Visibilité publique vérifiée et confirmée volontaire. CoreSimulator inaccessible depuis la session ; aucun rendu Flutter actuel ni test Flutter validé par cet audit.
- 24 octobre, intégration V1 après accord utilisateur : polices, palette, clair forcé, deux écrans, suppression avec annulation 5 s, retrait Archives/suggestions, icône plume, iOS 17, iPhone/portrait, région `fr`. Preuves :
  - Automatisé (Flutter 3.47.7 / Dart 3.13.5) : `dart format` sans changement, `flutter analyze` sans problème, `flutter test` 47 tests réussis (avant intervention : 29 réussis).
  - Simulateur iPhone 17, iOS 27.1, 402 × 874 points, ×3, vierge (aucune donnée personnelle), pensées fictives des références saisies par un harnais temporaire hors dépôt via le vrai stockage fichier : Capture, À traiter, feuille, toast « Annuler », annulation restaurée, clavier AZERTY clair, confirmation de dépôt. Captures dans [design/validation](design/validation/).
  - Persistance iOS : application terminée puis relancée avec le build normal ; compteur conservé (6), pensée restaurée par Annuler présente. Mode sombre système : app claire. Texte « accessibility-extra-large » : défilement sans coupure, titre et compteur empilés.
  - Non vérifié : VoiceOver réel (libellés seulement testés en widget), appareil physique, petit écran physique type SE (seul 320 × 568 testé en widget), migration de l’ancien chemin sur iOS, sauvegardes système.
- Le précédent contrôle de publication indiquait Gitleaks 8.30.1 sans détection le 20 octobre. Ce résultat n’est pas une certification de l’arbre actuel : refaire un contrôle adapté avant publication, sans exposer les secrets ni les fichiers ignorés. `pubspec.lock` reste utile à la reproductibilité.

Décisions résolues : Posé remplace le nom « Plus tard » ; iOS uniquement remplace « iOS en premier » ; publication App Store devient l’objectif ; polices et palette validées remplacent les approximations PNG ; traitement/suppression remplacent le parcours Archives ; suggestions et mode sombre sortent de V1. Les anciens identifiants D1–D10 ne portent plus de décisions produit ouvertes.

Compléments confirmés : logotype « posé. » en Newsreader Italic ; plume silhouette choisie, intégrée au catalogue AppIcon le 24 octobre ; iOS ≥17 ; dépôt public volontaire, sans licence open source accordée ; suppression immédiate avec annulation temporaire.

Décisions du 24 octobre (validées) : annulation 5 s, nouvelle suppression clôturant la précédente, « Réessayer » après échec d’annulation, clavier non ouvert au lancement, confirmation de dépôt jusqu’à la frappe suivante, aucune animation spécifique pour l’instant, iPhone et portrait uniquement, polices google/fonts (OFL), `restore`/`archived` conservés sans interface.

Décisions encore en attente : appareils iPhone de validation, animations éventuelles, adaptations de contraste à confirmer visuellement (voir DESIGN). Contrôler les sauvegardes système et les déclarations de confidentialité avant publication. Ces points n’autorisent aucun ajout fonctionnel.
