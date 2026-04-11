---
name: tsv-analyst
description: "Use this skill any time the user wants to perform calculations, aggregations, or statistical analysis on a TSV (or CSV) file and get the results as a structured TSV. Trigger for tasks like: computing totals, averages, percentages, rankings; building KPI summaries or indicator tables from raw data exports; comparing metrics across categories, time periods, or groups; calculating compliance or anomaly rates. Trigger whenever the user uploads or references a TSV/CSV file and wants to derive indicators, metrics, or summaries — even if they don't use 'TSV' or 'calculate'. Also trigger for 'verification file', 'indicator table', or 'KPI summary' requests. The key signal: raw tabular data → computed results the user can trust and verify. Do NOT trigger when the user only wants to view, format, or clean a file, or when the output should be a chart, Word doc, or presentation."
---

# TSV Analyst — Calculs Python sur données tabulaires

Ce skill transforme n'importe quel fichier TSV (ou CSV) en un tableau structuré d'indicateurs calculés avec Python, vérifiables et reproductibles.

## Philosophie

Les calculs sur des données volumineuses doivent être confiés à du code déterministe, pas à l'estimation du modèle. Ce skill génère et exécute du code Python (pandas) pour garantir l'exactitude des résultats — puis structure la sortie dans un TSV lisible et vérifiable par l'utilisateur.

La transparence est centrale : chaque indicateur du TSV de sortie documente la formule Python utilisée et les colonnes sources, pour que l'utilisateur puisse reproduire ou contester n'importe quel chiffre.

---

## Workflow

### Étape 1 — Chargement et inspection du fichier

Charge le fichier TSV/CSV avec pandas. Commence toujours par une inspection rapide :

```python
import pandas as pd

# Détection automatique du séparateur
df = pd.read_csv(filepath, sep=None, engine='python', encoding='utf-8-sig')

print(f"Dimensions : {df.shape[0]} lignes × {df.shape[1]} colonnes")
print(f"\nColonnes et types :\n{df.dtypes}")
print(f"\nAperçu :\n{df.head(3).to_string()}")
print(f"\nValeurs manquantes :\n{df.isnull().sum()[df.isnull().sum() > 0]}")
```

Présente à l'utilisateur en quelques lignes :
- Les dimensions du fichier
- Les colonnes identifiées (numériques, catégorielles, dates, booléennes)
- La période couverte si une colonne date est détectée
- Les anomalies évidentes (valeurs manquantes, doublons potentiels)

### Étape 2 — Résolution des ambiguïtés avant tout calcul

Avant de confirmer les indicateurs à calculer, **résous les ambiguïtés sémantiques** en mappant les termes utilisés par l'utilisateur vers les colonnes réelles du fichier.

Pour chaque terme clé dans la demande de l'utilisateur (catégorie, département, type, service, région, nature, etc.), identifie les colonnes candidates dans le fichier. Si plusieurs colonnes correspondent, présente les options et demande à l'utilisateur de choisir **avant** de calculer quoi que ce soit.

Exemple de résolution d'ambiguïté :
> L'utilisateur demande "top 5 des services". Le fichier contient deux colonnes candidates :
> - `Service` (valeurs : CRIT NATIONAL, CRIT OUEST, CRIT NORD…) → départements
> - `Domaine d'activité` (valeurs : Hôtel, Train, Vol, Frais…) → types de transport
>
> → Demander : "Par 'services', voulez-vous dire les départements (colonne `Service`) ou les types de dépenses (colonne `Domaine d'activité`) ?"

Cette étape est non négociable : une mauvaise interprétation silencieuse produit des chiffres corrects mais pour la mauvaise question. Il vaut mieux demander 10 secondes que livrer une analyse inexacte.

### Étape 3 — Confirmation des indicateurs à calculer

Une fois les ambiguïtés résolues, si l'utilisateur n'a pas encore précisé ce qu'il veut calculer, propose une liste d'indicateurs déduits automatiquement de la structure du fichier. Regroupe-les en familles logiques (Volume, Répartition, Conformité, Temporalité, Classements). Attends confirmation avant de passer au calcul.

Si l'utilisateur a déjà listé ses indicateurs, synthétise ce que tu as compris — en nommant les colonnes exactes que tu vas utiliser — et demande validation avant d'exécuter.

### Étape 4 — Génération et exécution du code Python

Pour chaque indicateur demandé, génère du code pandas clair et lisible. Montre le code à l'utilisateur **avant** de l'exécuter — cela renforce la confiance et permet la correction.

**Principes de génération du code :**

- Utilise des variables intermédiaires bien nommées plutôt que des one-liners illisibles
- Filtre les données avant d'agréger (ex : exclure les annulations si pertinent)
- Gère explicitement les valeurs nulles (dropna ou fillna selon le contexte)
- Arrondis les pourcentages à 1 décimale, les montants à 2 décimales
- Documente chaque bloc avec un commentaire `# Indicateur : nom`

Exemple de pattern pour un agrégat par catégorie :

```python
# Indicateur : Dépenses totales par type de transport
# Colonne utilisée : 'Domaine d'activité' (types : Hôtel, Train, Vol, Frais)
df_actif = df[df['Active'] == 'Oui']  # filtre sur lignes actives
total_par_type = (
    df_actif
    .groupby("Domaine d'activité")['Montant de la transaction(€)']
    .sum()
    .round(2)
    .sort_values(ascending=False)
)
```

### Étape 5 — Construction du TSV de sortie

Une fois tous les calculs exécutés, consolide les résultats dans un DataFrame pandas avec exactement ces 6 colonnes :

| Colonne | Description |
|---------|-------------|
| `Famille` | Catégorie de l'indicateur (ex : "Volume & Montants") |
| `Indicateur` | Nom précis de l'indicateur |
| `Valeur` | Résultat formaté lisiblement (ex : "1 234 567 €", "42,3 %", "127 lignes") |
| `Périmètre_Filtre` | Filtre appliqué (ex : "Active='Oui'", "Toutes lignes", "Année=2025") |
| `Formule_Python` | Expression pandas synthétique (ex : `df[filtre].groupby('col')['montant'].sum()`) |
| `Colonnes_Sources` | Noms exacts des colonnes utilisées, séparés par des virgules |

Sauvegarde le résultat :

```python
results_df.to_csv(output_path, sep='\t', index=False, encoding='utf-8-sig')
```

Sauvegarde aussi le script Python complet utilisé (pour auditabilité) :

```python
with open(script_output_path, 'w', encoding='utf-8') as f:
    f.write(full_script_code)
```

### Étape 6 — Points de vigilance

Après la production du TSV, signale systématiquement :
- Les hypothèses prises (ex : "Les lignes annulées ont été exclues du total des dépenses")
- Les colonnes ambiguës ou dont l'interprétation est incertaine
- Les indicateurs pour lesquels une vérification manuelle sur un échantillon est recommandée

---

## Règles importantes

**Résoudre avant de calculer** : toujours mapper les termes de l'utilisateur vers les colonnes réelles du fichier. Si un terme peut désigner plusieurs colonnes différentes, demander avant de supposer.

**Exactitude avant tout** : ne jamais estimer ou approximer un calcul — si pandas peut le calculer, il doit le calculer. Si un calcul est impossible (données insuffisantes, colonne introuvable), le dire explicitement.

**Code d'abord** : toujours montrer le code avant de l'exécuter. L'utilisateur doit pouvoir corriger une mauvaise interprétation avant que les calculs ne soient faits.

**Fichiers de sortie dans le dossier de travail** : sauvegarder le TSV résultat et le script `.py` dans le dossier de travail de l'utilisateur, pas dans un répertoire temporaire.

**Nommage des fichiers de sortie** : utiliser un nom descriptif, par exemple `indicateurs_[nom_fichier_source]_[date].tsv` et `calculs_[nom_fichier_source]_[date].py`.

**Séparateur de sortie** : toujours utiliser la tabulation (`\t`) comme séparateur dans le TSV de sortie, et l'encodage `utf-8-sig` pour garantir la compatibilité avec Excel.

---

## Étape suivante

Une fois le TSV validé par l'utilisateur, orienter vers le skill **TSV → Présentation HTML** pour transformer les indicateurs en une présentation visuelle.
