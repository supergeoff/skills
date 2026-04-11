---
name: tsv-analyst
description: "Use this skill any time the user wants to perform calculations, aggregations, or statistical analysis on a TSV (or CSV) file and get the results as a structured TSV. Trigger for tasks like: computing totals, averages, percentages, rankings; building KPI summaries or indicator tables from raw data exports; comparing metrics across categories, time periods, or groups; calculating compliance or anomaly rates. Trigger whenever the user uploads or references a TSV/CSV file and wants to derive indicators, metrics, or summaries — even if they don't use 'TSV' or 'calculate'. Also trigger for 'verification file', 'indicator table', or 'KPI summary' requests. The key signal: raw tabular data → computed results the user can trust and verify. Do NOT trigger when the user only wants to view, format, or clean a file, or when the output should be a chart, Word doc, or presentation."
---

# TSV Analyst — Python Calculations on Tabular Data

This skill transforms any TSV (or CSV) file into a structured table of indicators calculated with Python, which are verifiable and reproducible.

## Philosophy

Calculations on large datasets must be entrusted to deterministic code, not to the model's estimation. This skill generates and executes Python code (pandas) to guarantee the accuracy of the results — then structures the output into a TSV that is readable and verifiable by the user.

Transparency is central: each indicator in the output TSV documents the Python formula used and the source columns, so that the user can reproduce or challenge any figure.

---

## Workflow

### Step 1 — File Loading and Inspection

Load the TSV/CSV file with pandas. Always start with a quick inspection:

```python
import pandas as pd

# Automatic detection of the separator
df = pd.read_csv(filepath, sep=None, engine='python', encoding='utf-8-sig')

print(f"Dimensions : {df.shape[0]} rows × {df.shape[1]} columns")
print(f"\nColumns and types:\n{df.dtypes}")
print(f"\nPreview:\n{df.head(3).to_string()}")
print(f"\nMissing values:\n{df.isnull().sum()[df.isnull().sum() > 0]}")
```

Present to the user in a few lines:
- The file dimensions
- The identified columns (numeric, categorical, dates, booleans)
- The covered period if a date column is detected
- Obvious anomalies (missing values, potential duplicates)

### Step 2 — Resolving Ambiguities Before Any Calculation

Before confirming the indicators to calculate, **resolve semantic ambiguities** by mapping the terms used by the user to the actual columns in the file.

For each key term in the user's request (category, department, type, service, region, nature, etc.), identify the candidate columns in the file. If multiple columns match, present the options and ask the user to choose **before** calculating anything.

Ambiguity resolution example:
> The user asks for the "top 5 services". The file contains two candidate columns:
> - `Service` (values: NATIONAL DIV, WEST BU, NORTH BU...) → departments
> - `Business Area` (values: Hotel, Train, Flight, Expenses...) → transport types
>
> → Ask: "By 'services', do you mean the departments (`Service` column) or the expense types (`Business Area` column)?"

This step is non-negotiable: silent misinterpretation produces correct figures but for the wrong question. It is better to ask for 10 seconds than to deliver an inaccurate analysis.

### Step 3 — Confirmation of Indicators to Calculate

Once ambiguities are resolved, if the user hasn't specified what they want to calculate yet, propose a list of indicators automatically deduced from the file structure. Group them into logical families (Volume, Distribution, Compliance, Temporality, Rankings). Wait for confirmation before proceeding to calculation.

If the user has already listed their indicators, summarize what you understood — naming the exact columns you will use — and ask for validation before executing.

### Step 4 — Python Code Generation and Execution

For each requested indicator, generate clear and readable pandas code. Show the code to the user **before** executing it — this builds trust and allows for correction.

**Code generation principles:**

- Use well-named intermediate variables rather than unreadable one-liners
- Filter data before aggregating (e.g., exclude cancellations if relevant)
- Explicitly handle null values (dropna or fillna depending on context)
- Round percentages to 1 decimal place, amounts to 2 decimal places
- Document each block with a comment `# Indicator: name`

Pattern example for an aggregate by category:

```python
# Indicator: Total expenses by transport type
# Column used: 'Business Area' (types: Hotel, Train, Flight, Expenses)
df_active = df[df['Active'] == 'Yes']  # filter on active rows
total_by_type = (
    df_active
    .groupby("Business Area")['Transaction Amount(€)']
    .sum()
    .round(2)
    .sort_values(ascending=False)
)
```

### Step 5 — Construction of the Output TSV

Once all calculations are executed, consolidate the results into a pandas DataFrame with exactly these 6 columns:

| Column | Description |
|---------|-------------|
| `Family` | Indicator category (e.g.: "Volume & Amounts") |
| `Indicator` | Precise name of the indicator |
| `Value` | Readably formatted result (e.g.: "1,234,567 €", "42.3 %", "127 rows") |
| `Scope_Filter` | Applied filter (e.g.: "Active='Yes'", "All rows", "Year=2025") |
| `Python_Formula` | Synthetic pandas expression (e.g.: `df[filter].groupby('col')['amount'].sum()`) |
| `Source_Columns` | Exact names of the used columns, separated by commas |

Save the result:

```python
results_df.to_csv(output_path, sep='\t', index=False, encoding='utf-8-sig')
```

Also save the complete Python script used (for auditability):

```python
with open(script_output_path, 'w', encoding='utf-8') as f:
    f.write(full_script_code)
```

### Step 6 — Points of Vigilance

After producing the TSV, systematically point out:
- The assumptions made (e.g.: "Cancelled rows were excluded from total expenses")
- Ambiguous columns or those with uncertain interpretation
- Indicators for which manual verification on a sample is recommended

---

## Important Rules

**Resolve before calculating**: always map the user's terms to the actual columns in the file. If a term could refer to several different columns, ask before assuming.

**Accuracy above all**: never estimate or approximate a calculation — if pandas can calculate it, it must calculate it. If a calculation is impossible (insufficient data, column not found), explicitly say so.

**Code first**: always show the code before executing it. The user must be able to correct a misinterpretation before the calculations are made.

**Output files in the working directory**: save the resulting TSV and the `.py` script in the user's working directory, not in a temporary directory.

**Output file naming**: use a descriptive name, for example `indicators_[source_file_name]_[date].tsv` and `calculations_[source_file_name]_[date].py`.

**Output separator**: always use the tab character (`\t`) as a separator in the output TSV, and `utf-8-sig` encoding to ensure compatibility with Excel.

---

## Next Step

Once the TSV is validated by the user, steer them towards the **TSV → HTML Presentation** skill to transform the indicators into a visual presentation.
