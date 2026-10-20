# Contrôle avant publication — 20 octobre 2026

## Périmètre

- Historique Git accessible via toutes les références locales après récupération des branches et tags distants.
- Ensemble final des fichiers préparés pour le commit, exporté séparément pour exclure les fichiers de compilation et caches locaux.
- Vérification des chemins publiés : absence de fichiers `.env`, clés privées, certificats de signature et paramètres locaux Claude Code.
- Le dépôt distant ne contient à cette date qu’une branche `main`, aucune issue, pull request, release ou artefact Actions.

## Méthode et résultat

Gitleaks 8.30.1, règles par défaut, sortie expurgée : aucun secret détecté dans l’historique existant ni dans les fichiers destinés au commit lors du contrôle préalable. Le contrôle est répété sur l’historique final avant publication.

Le `.gitignore` exclut les fichiers d’environnement, clés/certificats, profils de signature et fichiers locaux de configuration. Le fichier `pubspec.lock` est conservé pour la reproductibilité de l’application.

Ce contrôle recherche des motifs connus ; il ne constitue pas une garantie d’absence de secret. Les données utilisateur et fichiers de compilation ne sont pas inclus dans le dépôt.
