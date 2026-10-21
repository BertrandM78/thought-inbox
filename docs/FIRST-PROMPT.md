# Reprendre avec Claude Code

À lancer depuis la racine Flutter. La base fonctionnelle existe déjà : ne pas demander sa réimplémentation.

```text
Lis CLAUDE.md, README.md, docs/AUDIT.md, docs/PRODUCT.md, docs/DESIGN.md,
docs/ARCHITECTURE.md et docs/ROADMAP.md. Inspecte git status et les différences
indexées/non indexées avant de modifier quoi que ce soit. Préserve les quatre
fichiers déjà modifiés pour path_provider. Ouvre les deux PNG de
docs/design/reference/ et leur manifeste.

Travaille sur M2 uniquement : reproduire les écrans Capture et À traiter à partir
des captures Lovable. Présente d’abord un bref constat de l’existant et les
fichiers que tu vas toucher, puis réalise le travail. Réutilise l’architecture
modèle/stockage/contrôleur/UI, extrais les tokens et les widgets nécessaires sans
réécrire le modèle ni le stockage. Confirme les polices si un export Lovable est
présent ; sinon signale l’approximation. Utilise les cinq exemples du manifeste
dans une fixture isolée du stockage et du démarrage de production. Ne rends pas
les suggestions artificiellement fonctionnelles.

Livre les deux rendus de comparaison à un viewport documenté, vérifie un petit
écran, le clavier et les textes longs. Si le simulateur ou une dépendance est
indisponible, indique le blocage et ne déclare pas la fidélité validée. Exécute
formatage, flutter analyze et flutter test pour les changements de code.
Mets à jour ROADMAP.md avec les résultats réellement obtenus. Ne crée aucun
commit et ne pousse rien. Termine par les captures, les écarts restants et le
point précis à valider visuellement avant M3.
```

Pour clôturer M1 avant M2 : demander à Claude de suivre la validation iOS de `docs/MILESTONE-1.md`, en vérifiant particulièrement les données existantes et le chemin `path_provider`. Cette validation n’exige pas de refaire l’interface.
