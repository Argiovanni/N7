# CHANGELOG

## [2.0.0] - 2024-12-16
### Ajouts
- **[RELEASE]** `HagiMule_v2.0`. ([?])
- **[FEATURE]** Compress all available files and fix issues in partial compression. ([92209fba])
- **[FEATURE]** Logging information of downloads in a log file. ([00a3205b])

### Corrections
- **[FIX]** Retry download when a chunk fails and cancel the download if retries are exhausted. ([936bd96c])
- **[FIX]** Download folder handling improvements. ([e5fbcb6d])
- **[FIX]** Corrected the value of max packet size in binary format (1024). ([fb14a5b1])

### Nettoyages
- **[CLEAN]** Refactored code for better clarity and maintainability. ([2611401a], [d9b47a82])

### Mineures
- **[MINOR]** Fixed the calculation of usage rates in the downloader. ([9a5d788])

### Mises à jour
- **[UPDATE]** Updated `README` to reflect the latest changes and features. ([ee7c6cd7], [011bccd1])
- **[UPDATE]** Parameterized latency and packet size in the daemon. ([e949a221])
- **[UPDATE]** Parameterized storage path and server address in the downloader. ([d1b0a5a4])
- **[UPDATE]** Refactored downloader code for better performance. ([e7e6e025])

## [1.0.0] - 2024-12-10
### Ajouts
- **[RELEASE]** Première version officielle : `HagiMule_v1.0`. ([789e77c5])

### Corrections
- **[FIX]** Correction du calcul des taux de conversion en float. ([3d6a6bf4])
- **[FIX]** Téléchargement fonctionnel à partir de cette version. ([d0c40b4e])
- **[FIX]** Dissociation des ports disponibles et des ports liés. ([9cde3c0e])

### Nettoyages
- **[CLEAN]** Style et indentation améliorés dans plusieurs fichiers. ([81804414], [0d27d93f])

### Mineures
- **[MINOR]** Suppression d'un import inutilisé. ([d0c40b4e])

### Mises à jour
- **[UPDATE]** Mise à jour du fichier `README` pour suivre les dernières modifications. ([ee7c6cd7])


[92209fba]:(https://git.inpt.fr/bedrossianp/hagimule/commit/92209fba)
[00a3205b]:(https://git.inpt.fr/bedrossianp/hagimule/commit/00a3205b)
[936bd96c]:(https://git.inpt.fr/bedrossianp/hagimule/commit/936bd96c)
[e5fbcb6d]:(https://git.inpt.fr/bedrossianp/hagimule/commit/e5fbcb6d)
[fb14a5b1]:(https://git.inpt.fr/bedrossianp/hagimule/commit/fb14a5b1)
[2611401a]:(https://git.inpt.fr/bedrossianp/hagimule/commit/2611401a)
[d9b47a82]:(https://git.inpt.fr/bedrossianp/hagimule/commit/d9b47a82)
[9a5d788]:(https://git.inpt.fr/bedrossianp/hagimule/commit/9a5d788)
[ee7c6cd7]:(https://git.inpt.fr/bedrossianp/hagimule/commit/ee7c6cd7)
[011bccd1]:(https://git.inpt.fr/bedrossianp/hagimule/commit/011bccd1)
[e949a221]:(https://git.inpt.fr/bedrossianp/hagimule/commit/e949a221)
[d1b0a5a4]:(https://git.inpt.fr/bedrossianp/hagimule/commit/d1b0a5a4)
[e7e6e025]:(https://git.inpt.fr/bedrossianp/hagimule/commit/e7e6e025)
[789e77c5]:(https://git.inpt.fr/bedrossianp/hagimule/commit/789e77c5)
[3d6a6bf4]:(https://git.inpt.fr/bedrossianp/hagimule/commit/3d6a6bf4)
[d0c40b4e]:(https://git.inpt.fr/bedrossianp/hagimule/commit/d0c40b4e)
[9cde3c0e]:(https://git.inpt.fr/bedrossianp/hagimule/commit/9cde3c0e)
[81804414]:(https://git.inpt.fr/bedrossianp/hagimule/commit/81804414)
[0d27d93f]:(https://git.inpt.fr/bedrossianp/hagimule/commit/0d27d93f)
[d0c40b4e]:(https://git.inpt.fr/bedrossianp/hagimule/commit/d0c40b4e)
[ee7c6cd7]:(https://git.inpt.fr/bedrossianp/hagimule/commit/ee7c6cd7)
