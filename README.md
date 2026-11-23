# Likelemba (prototype des écrans)

Tontine entre proches : calendrier des tours, déclaration et confirmation des paiements,
garanties graduées selon le rang, historique. Les données de ce prototype sont fictives et
restent en mémoire.

## Compiler sans rien installer

1. Créez un nouveau dépôt GitHub (par exemple `Likelemba`).
2. Envoyez-y le contenu de ce dossier : `lib/`, `pubspec.yaml`, `.gitignore`, `README.md`.
3. Créez le fichier `.github/workflows/build.yml` avec le contenu fourni (Add file, Create new file,
   et tapez le chemin complet depuis la racine du dépôt).
4. Onglet Actions, Build Likelemba APK, Run workflow. Téléchargez ensuite `likelemba-apk`.

Le dossier `android/` est généré par le workflow : il n'est pas à envoyer.

## Où se trouvent les règles de garantie

`lib/models.dart` : `maxLoss`, `requiredGuarantee`, `guarantorRequired`, `guarantorShare`.
