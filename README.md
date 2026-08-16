# Living Conditions and Territorial Inequality in Colombia — ECV 2025 (DANE)

Analysis of the **2025 National Quality of Life Survey (ECV)** produced by Colombia's National Administrative Department of Statistics (DANE). This academic project was developed at Universidad Externado de Colombia.

The project combines reproducible analysis in R and Python, geospatial visualization, and an interactive Power BI narrative to explore territorial differences in living conditions, access to services, income adequacy, and well-being. It was developed by a three-person team using the 2025 ECV dataset.

## Key findings

- Published a narrative Power BI dashboard, with data cleaning and transformation performed in Power Query.
- Built department-level geospatial maps in RStudio covering healthcare access, income adequacy, severe food insecurity, and life satisfaction.
- Developed a logistic regression model to estimate the probability of perceived poverty, achieving 77.6% accuracy and an AUC of 0.82.
- Income insufficiency emerged as the strongest predictor of perceived poverty, with an odds ratio of approximately 13, exceeding the effect of geographic access to healthcare services.

**Tools:** Power BI, Power Query, R, RStudio, Python, scikit-learn, and pandas.

## Interactive report

[View the published Power BI report](https://app.powerbi.com/view?r=eyJrIjoiMTQ4NDE5OTQtOTJlZi00MDc1LWI1YzgtNDBmMzIyN2U0YTg0IiwidCI6IjNiOTQ0ZDlhLTEwNTEtNDY4NS1iMDlkLTlhOTVlZTJkYmQ5OSIsImMiOjR9)

## Repository contents

- `analisis-r/`: RStudio project, cartographic script, exported maps, and department-level indicators.
- `notebooks/`: Python notebook used to consolidate variable metadata.
- `power-bi/`: Editable Power BI report file.
- `informes/`: Academic report, presentation, and AI-use disclosure.
- `diccionario/`: Consolidated data dictionary for the 2025 ECV.

## Cartographic indicators

The analysis includes four department-level visualizations:

1. Severe food insecurity.
2. Difficulty accessing hospitals.
3. Income insufficiency.
4. Life satisfaction.

Classification, scale, and color-palette decisions are documented in [`analisis-r/README_cartografia.md`](analisis-r/README_cartografia.md).

## Reproducing the analysis

1. Download the microdata from the [DANE 2025 ECV catalog](https://microdatos.dane.gov.co/index.php/catalog/905/get-microdata).
2. Download the department-level geographic data from the [DANE Geoportal](https://geoportal.dane.gov.co/).
3. Organize the files according to [`analisis-r/datos/README.md`](analisis-r/datos/README.md).
4. Open `analisis-r/Proyecto3_ECV2025.Rproj` in RStudio.
5. Install `tidyverse`, `sf`, `ggplot2`, `readr`, `classInt`, `RColorBrewer`, `openxlsx`, and `cowplot`.
6. Run `analisis-r/script_mapas.R` from beginning to end.

Calculations were performed on the survey sample without applying expansion weights. The results therefore represent patterns observed in the sample rather than population estimates.

## Data

The original microdata are not included in this repository because of their size. They must be obtained directly from DANE's official sources.

## Team

Academic project developed by the Lugo, Nieto, and Gómez team.
