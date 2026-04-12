---
name: tsv-to-slides
description: "Use this skill any time the user wants to transform a TSV or CSV file into a visual HTML slide deck — one slide per indicator, formatted for 16:9 print-to-PDF or import into Google Slides / PowerPoint. Trigger whenever the user mentions: 'slides', 'présentation', 'HTML', 'diapositives', 'rapport visuel', 'dashboard', 'mise en forme', 'visualiser mes données', or when they upload a TSV/CSV and want something visual out of it — even if they say 'PowerPoint', 'PDF', 'deck', or 'pitch'. Also trigger when the output of tsv-analyst needs to be visualised. This skill is particularly important to use when the user has just finished a tsv-analyst run and wants to present the results."
---

# TSV → Slides HTML

Transform any TSV or CSV file into a self-contained HTML slide deck — one indicator per slide, designed for 16:9 print-to-PDF or Google Slides / PowerPoint import.

## Philosophy

Each indicator deserves its own slide: one number, one chart, one table. The visual element adapts to the nature of the data — you don't explain a time series with a pie chart. **Values are always visible directly on the chart — never tooltip-only.** The file is entirely self-contained: no internet access required once generated. No iframes, no external references.

---

## Step 1 — Load and Inspect the File

Load the TSV or CSV with pandas (auto-detect separator):

```python
import pandas as pd
df = pd.read_csv(filepath, sep=None, engine='python', encoding='utf-8-sig')
print(df.shape, df.dtypes, df.head(3).to_string())
```

Detect which structure you're dealing with:
- **tsv-analyst output**: 6 columns — `Famille / Indicateur / Valeur / Périmètre_Filtre / Formule_Python / Colonnes_Sources`. Each row is already an indicator ready to visualise.
- **Generic TSV**: Any other structure. Identify numeric columns, date columns, categorical columns. Group rows into logical "families" of indicators if possible (by category, section, theme).

Announce what you found in 3–5 lines: structure type, number of indicators detected, any anomalies.

---

## Step 2 — Propose the Slide Plan

Before generating anything, propose a slide plan to the user. For each indicator (or group), specify:

- **Slide title**
- **Proposed chart type** (see chart selection guide below)
- **What the chart will show** — which column, what x/y axes or segments

Example:
```
1. Répartition des dépenses par nature → donut chart (segments = natures, % affiché sur chaque segment)
2. Top entités par budget → horizontal bar chart (top 14 triées, valeur en k€ sur chaque barre)
3. Conformité politique voyage → progress bars HTML (couleur seuil vert/orange/rouge, % affiché)
4. Frais Egencia online vs offline → pie chart (% affiché sur chaque segment)
```

**Also ask** at this step:
- Couleurs principales (hex codes) — default: `#003366` primary, `#E8341C` accent, `#1DB36E` positive, `#F59E0B` warning, `#EF4444` danger
- Police souhaitée — default: `Segoe UI, system-ui, sans-serif`
- Nom de l'entreprise / titre général de la présentation

**Wait for the user's confirmation** before generating.

---

## Chart Selection Guide

| Data pattern | Chart type |
|---|---|
| Parts d'un tout (répartitions en %) | **Donut / Pie** |
| Classement / Top-N / Groupes discrets | **Horizontal bar chart** |
| Évolution dans le temps (trimestres, mois, années) | **Line chart** |
| Comparaison de catégories sur plusieurs dimensions | **Grouped bar chart** |
| Cumul sur des catégories (part + volume) | **Stacked bar chart** |
| Taux / % de conformité / scores sur plusieurs items | **Progress bars HTML** |
| Distribution géographique ou matricielle | **Heatmap CSS** |

---

## Step 3 — Generate the HTML

After validation, generate one self-contained HTML file. All CSS, JavaScript, and Chart.js must be **fully embedded inline** — no CDN links, no iframes, no external file references. The file must open in any browser directly from the filesystem (`file://`) without errors.

### How to embed Chart.js inline

**Chart.js is pre-bundled in this skill's scripts directory.** Read it directly — do NOT try to fetch it from the internet (that approach produces truncated embeds).

```python
chartjs_path = "/sessions/sleepy-practical-hamilton/tsv-to-slides/scripts/chart.umd.min.js"
with open(chartjs_path, encoding='utf-8') as f:
    chartjs_inline = f.read()
# Inject into HTML: <script>{chartjs_inline}</script>
# The embedded script is ~200k chars — this is expected and correct.
```

### Slide format (16:9) — "Projection-first" mindset

These slides will be **projected on screen**, not read on paper. Every sizing, font, and spacing decision must serve legibility at distance.

```css
.slide {
  width: 297mm;
  height: 167mm;
  position: relative;
  overflow: hidden;
  box-sizing: border-box;
  background: white;
  font-family: 'Segoe UI', system-ui, sans-serif;
}
@media print {
  .slide { page-break-after: always; break-after: page; }
  @page { size: A4 landscape; margin: 0; }
}
```

**Typography minimums for projection:**
- Slide title: `22px`, `font-weight: 700`
- Section headers / axis labels: `16px`, `font-weight: 600`
- Body text / table cells: `15px` minimum — never go below `14px`
- Insight chips: `13px`
- Footer / source note: `12px`

**Margins — generous breathing room:**
- Slide inner padding: `24px 32px` (top/bottom 24px, left/right 32px)
- The chart and the detail table must each have their own internal padding — do not let content touch the column separator or the slide edge

### Slide layout (two columns, 55 / 45)

```
┌──────────────────────────────────────────────────────┐
│ [SLIDE TITLE 22px bold]         [company · date 12px]│
├──────────┬─────────────────┬──────────────────────────┤
│  32px    │  CHART — 50%   │   DÉTAIL — 38%   │ 32px  │
│  margin  │                │  (separator 12px) │ margin│
│          │  [Canvas]      │  ┌────────┬──────┐│       │
│          │                │  │ Label  │Valeur││       │
│          │  values shown  │  │ ...    │ ...  ││       │
│          │  directly on   │  └────────┴──────┘│       │
│          │  chart         │                   │       │
│          │                │  [insight chips]  │       │
├──────────┴─────────────────┴───────────────────┴──────┤
│ [Périmètre source — 12px]              Slide N / T   │
└──────────────────────────────────────────────────────┘
```

Use CSS Grid for the two-column layout:
```css
.slide-body {
  display: grid;
  grid-template-columns: 1fr 12px 0.72fr;  /* chart | gap | table */
  gap: 0;
  height: calc(100% - 52px - 28px);  /* minus header and footer */
  padding: 16px 32px;
  align-items: start;
}
.chart-col { padding-right: 16px; }
.divider   { border-right: 1px solid #E5E7EB; }
.detail-col { padding-left: 20px; }
```

---

## ⚠️ CRITICAL — Values Always Visible on Charts

**Never rely on hover/tooltip alone.** All values must appear directly on the chart. Implement this with a custom Chart.js plugin that draws labels after render.

### Universal inline datalabels plugin (include in every HTML)

```javascript
// Paste this BEFORE creating any Chart instance
const DataLabelsPlugin = {
  id: 'datalabels',
  afterDatasetsDraw(chart) {
    const ctx = chart.ctx;
    chart.data.datasets.forEach((dataset, i) => {
      const meta = chart.getDatasetMeta(i);
      if (meta.hidden) return;
      meta.data.forEach((element, index) => {
        const value = dataset.data[index];
        if (value === null || value === undefined) return;
        
        // Format the label
        const label = dataset._labelFormatter 
          ? dataset._labelFormatter(value) 
          : value;
        
        ctx.save();
        ctx.fillStyle = element.options?.backgroundColor === '#fff' ? '#333' : '#fff';
        ctx.font = 'bold 11px Segoe UI, sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        
        // Position: use the element's center
        const x = element.x;
        const y = element.y;
        ctx.fillText(label, x, y);
        ctx.restore();
      });
    });
  }
};
Chart.register(DataLabelsPlugin);
```

### Pie / Donut — show % on each segment

For pie and donut charts, draw labels inside each segment using a dedicated afterDraw hook:

```javascript
const PieLabelPlugin = {
  id: 'pieLabels',
  afterDraw(chart) {
    if (!['pie', 'doughnut'].includes(chart.config.type)) return;
    const ctx = chart.ctx;
    const dataset = chart.data.datasets[0];
    const total = dataset.data.reduce((a, b) => a + b, 0);
    
    chart.getDatasetMeta(0).data.forEach((arc, i) => {
      const pct = ((dataset.data[i] / total) * 100).toFixed(1);
      if (pct < 3) return; // skip tiny slices
      
      // Midpoint angle of the arc
      const midAngle = arc.startAngle + (arc.endAngle - arc.startAngle) / 2;
      // Position at 65% of the way to the outer radius (inside the segment)
      const r = (arc.outerRadius + arc.innerRadius) / 2 || arc.outerRadius * 0.65;
      const x = arc.x + Math.cos(midAngle) * r;
      const y = arc.y + Math.sin(midAngle) * r;
      
      ctx.save();
      ctx.fillStyle = '#fff';
      ctx.font = 'bold 12px Segoe UI, sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.shadowColor = 'rgba(0,0,0,0.5)';
      ctx.shadowBlur = 3;
      ctx.fillText(pct + ' %', x, y);
      ctx.restore();
    });
  }
};
Chart.register(PieLabelPlugin);
```

### Horizontal bar chart — show value at end of each bar

```javascript
// In the chart options:
options: {
  plugins: {
    legend: { display: false },
    tooltip: { enabled: true }
  },
  layout: { padding: { right: 60 } },  // space for labels
  animation: {
    onComplete: function() {
      const ctx = this.ctx;
      this.data.datasets.forEach((dataset, i) => {
        const meta = this.getDatasetMeta(i);
        meta.data.forEach((bar, j) => {
          const value = dataset.data[j];
          const label = dataset._labelFormatter ? dataset._labelFormatter(value) : value;
          ctx.save();
          ctx.fillStyle = '#333';
          ctx.font = 'bold 11px Segoe UI, sans-serif';
          ctx.textAlign = 'left';
          ctx.textBaseline = 'middle';
          ctx.fillText(label, bar.x + 6, bar.y);
          ctx.restore();
        });
      });
    }
  }
}
```

### Line chart — show value at each data point

```javascript
// Use the universal DataLabelsPlugin above, with positioning adjusted for line charts:
// Place label ABOVE the point
afterDatasetsDraw(chart) {
  chart.data.datasets.forEach((dataset, i) => {
    const meta = chart.getDatasetMeta(i);
    meta.data.forEach((point, j) => {
      const value = dataset.data[j];
      const label = dataset._labelFormatter ? dataset._labelFormatter(value) : value;
      ctx.fillText(label, point.x, point.y - 12); // 12px above the point
    });
  });
}
```

---

## Progress Bars (for rate/compliance slides)

Use pure HTML/CSS — no Chart.js needed. Sized for projection: large enough to read at distance.

```html
<div class="progress-item">
  <div class="progress-label">
    <span class="prog-name">Hôtel</span>
    <span class="prog-pct" style="color: #EF4444;">52,9 %</span>
  </div>
  <div class="progress-track">
    <div class="progress-fill" style="width: 52.9%; background: #EF4444;"></div>
  </div>
  <div class="progress-count">1 620 transactions évaluées</div>
</div>
```

```css
.progress-item { margin-bottom: 18px; }   /* generous spacing between items */
.progress-label {
  display: flex;
  justify-content: space-between;
  margin-bottom: 6px;
  font-size: 15px;            /* readable when projected */
}
.prog-name { color: #374151; font-weight: 600; }
.prog-pct  { font-weight: 700; font-size: 16px; }   /* the % is the hero number */
.progress-track {
  height: 14px;               /* thicker bar — visible at projection distance */
  background: #E5E7EB;
  border-radius: 99px;
  overflow: hidden;
}
.progress-fill { height: 100%; border-radius: 99px; }
.progress-count { font-size: 13px; color: #9CA3AF; margin-top: 4px; }
```

**Threshold colours** — apply in JavaScript when building the bars:
```javascript
function thresholdColor(pct) {
  if (pct >= 80) return '#1DB36E';  // green
  if (pct >= 60) return '#F59E0B';  // orange
  return '#EF4444';                  // red
}
```

---

## Detail Table (right column) — Style Requirements

The detail table must look polished and be easy to read at projection distance. It is NOT a raw HTML table dump — it is a styled presentation element.

```css
.detail-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;           /* minimum — 13px absolute floor */
  margin-top: 8px;
}
.detail-table th {
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.6px;
  color: #6B7280;
  font-weight: 600;
  padding: 6px 10px;
  border-bottom: 2px solid #E5E7EB;
  text-align: left;
}
.detail-table td {
  padding: 8px 10px;         /* generous cell padding */
  font-size: 14px;
  color: #111827;
  border-bottom: 1px solid #F3F4F6;
  white-space: nowrap;
}
.detail-table tr:last-child td { border-bottom: none; }
.detail-table tr:nth-child(even) td { background: #F9FAFB; }
/* Right-align numeric columns */
.detail-table td.num { text-align: right; font-weight: 600; font-variant-numeric: tabular-nums; }
/* Total row */
.detail-table tr.total td { font-weight: 700; border-top: 2px solid #E5E7EB; border-bottom: none; color: #003366; }
```

**Never let the table overflow the slide edge.** Constrain it with `max-height` and `overflow: hidden` if there are many rows, and prefer showing fewer rows with better spacing over cramming everything in. For large datasets, show the top 8–10 rows with a "…et N autres" note.

---

## ⚠️ MANDATORY — Insight Chips on EVERY Slide

**Every indicator slide must include at least 1–2 insight chips in the right column.** This is not optional. Even when the data looks "normal", always surface one observation — a high performer, a notable trend, a dominant contributor.

### Chip types

```html
<!-- Good / on target -->
<div class="insight good">✅ Vol : 100 % de conformité</div>
<!-- Alert / below threshold -->
<div class="insight alert">⚠️ Hôtel : seul domaine sous 60 %</div>
<!-- Informational / dominant -->
<div class="insight info">ℹ️ CRIT NATIONAL représente 47 % à lui seul</div>
```

```css
.insight { padding: 6px 10px; border-radius: 6px; font-size: 11px; margin-bottom: 6px; font-weight: 500; }
.insight.good  { background: #D1FAE5; color: #065F46; }
.insight.alert { background: #FEE2E2; color: #991B1B; }
.insight.info  { background: #DBEAFE; color: #1E40AF; }
```

### What to write in chips — decision guide

| Situation | Chip type | Example |
|---|---|---|
| Valeur max très au-dessus des autres | `.info` | ℹ️ Paris pèse 44 % du total |
| Valeur min nettement sous la moyenne | `.alert` | ⚠️ Q1 2024 : point bas à -12 % |
| Taux ≥ 80 % | `.good` | ✅ Conformité globale : 83 % |
| Taux < 60 % | `.alert` | ⚠️ Taux hôtel sous le seuil cible |
| Tendance claire | `.info` | ℹ️ Hausse continue sur 3 trimestres |
| Données homogènes, pas d'outlier | `.info` | ℹ️ Écart faible entre régions (< 5 %) |

### Chart outlier styling

In addition to chips, **visually highlight the standout item on the chart itself**:
- **Dominant value**: use primary colour for its bar/segment, muted `#9CA3AF` for others
- **Below threshold**: use `#EF4444` (red) for that bar/segment specifically
- **Best performer**: use `#1DB36E` (green) for it

---

## KPI Summary Slide

The summary slide (slide 2, after the cover) shows 4–6 key numbers as cards. Use a clean 2×2 or 3×2 grid — **no chart, just large numbers with context**. Font sizes must be large enough to read projected:

```html
<div class="kpi-grid">
  <div class="kpi-card" style="border-top: 4px solid #003366;">
    <div class="kpi-label">Dépenses totales</div>
    <div class="kpi-value">584 k€</div>
    <div class="kpi-sub">Transactions actives YTD</div>
  </div>
  <!-- ... -->
</div>
```

```css
.kpi-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
  padding: 20px 32px;
  height: calc(100% - 56px);
  align-content: center;
}
.kpi-card {
  background: #F9FAFB;
  border-radius: 12px;
  padding: 22px 20px;
  border-top: 4px solid #003366;
}
.kpi-label {
  font-size: 12px;         /* min 12px even for labels */
  text-transform: uppercase;
  letter-spacing: 0.8px;
  color: #6B7280;
  margin-bottom: 8px;
  font-weight: 600;
}
.kpi-value {
  font-size: 2.4rem;       /* large and readable when projected */
  font-weight: 800;
  color: #111827;
  line-height: 1;
}
.kpi-sub {
  font-size: 13px;         /* not smaller than 12px */
  color: #9CA3AF;
  margin-top: 6px;
}
```

---

## Value Formatting Rules

Show abbreviated values on charts, full values in detail tables:

| Raw value | On chart | In table |
|---|---|---|
| 261034.27 | `261 k€` | `261 034,27 €` |
| 0.447 | `44,7 %` | `44,7 %` |
| 4919 | `4 919 tx` | `4 919 transactions` |
| 0.529 | `52,9 %` | `52,9 %` |

French formatting: space as thousands separator, comma as decimal separator.

```javascript
function fmtAbbrev(v, type) {
  if (type === 'euro') return (v >= 1000 ? Math.round(v/1000) + ' k€' : v.toFixed(0) + ' €');
  if (type === 'pct')  return v.toFixed(1).replace('.', ',') + ' %';
  if (type === 'tx')   return v.toLocaleString('fr-FR') + ' tx';
  return v;
}
function fmtFull(v, type) {
  if (type === 'euro') return v.toLocaleString('fr-FR', {minimumFractionDigits: 2}) + ' €';
  if (type === 'pct')  return v.toFixed(1).replace('.', ',') + ' %';
  if (type === 'tx')   return v.toLocaleString('fr-FR') + ' transactions';
  return v;
}
```

---

## Step 4 — Save and Hand Off

Save to the user's working directory: `slides_[source_filename]_[YYYY-MM-DD].html`

Confirm:
- Number of slides generated
- How to export to PDF: open in Chrome → Ctrl+P → "Enregistrer en PDF" → A4 Paysage, marges Aucune
- How to import into Google Slides: Fichier → Importer des diapositives → upload the PDF
- Any slide where you made a judgment call (chart type, outlier threshold)

---

## Chart Variety — Avoid Bar Chart Monotony

Don't default to bar charts for everything. If a dataset has multiple numeric dimensions per category (e.g., absenteeism + satisfaction + turnover per department), consider:

- **Donut** for any single distribution that sums to 100 %
- **Radar / spider chart** for multi-dimensional profiles per category — ideal for RH data where you want to show each department across 4+ dimensions at once
- **Scatter plot** for correlation (e.g., absenteeism vs. turnover)
- **Stacked bar** when part + whole both matter
- **Line** whenever there's a time dimension — always prefer it over grouped bars for time series

For a Radar chart in Chart.js:
```javascript
new Chart(ctx, {
  type: 'radar',
  data: {
    labels: ['Absentéisme', 'Satisfaction', 'Turnover', 'Formation'],
    datasets: [{
      label: 'Opérations',
      data: [14.3, 5.9, 18.7, 61],
      borderColor: '#E8341C',
      backgroundColor: 'rgba(232,52,28,0.1)',
    }]
  },
  options: {
    scales: {
      r: {
        ticks: { font: { size: 12 } },
        pointLabels: { font: { size: 14, weight: '600' } }
      }
    }
  }
});
```

---

## Important Constraints

- **Never recalculate or modify values** from the input TSV
- **No iframes** — they trigger file:// security errors in browsers
- **No external file references** — all scripts, styles, fonts must be inline
- One indicator (or tightly related family) per slide — don't pack too much
- If TSV > 20 indicator rows, group related rows onto one slide and note it in the plan
- The HTML must open without JavaScript errors when loaded from `file://`
