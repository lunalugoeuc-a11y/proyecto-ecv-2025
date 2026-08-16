# Condiciones de vida y desigualdad territorial en Colombia - ECV 2025 (DANE)

Análisis de la **Encuesta Nacional de Calidad de Vida (ECV) 2025** del Departamento Administrativo Nacional de Estadística (DANE), desarrollado como proyecto académico en la Universidad Externado de Colombia.

El proyecto integra análisis reproducible en R y Python, visualización cartográfica y una narrativa interactiva en Power BI para explorar diferencias territoriales relacionadas con condiciones de vida, acceso a servicios, suficiencia de ingresos y bienestar. Fue desarrollado por un equipo de tres personas a partir de la ECV 2025.

## Resultados destacados

- Dashboard narrativo publicado en Power BI, con limpieza y transformación de datos en Power Query.
- Mapas geoespaciales departamentales en RStudio sobre acceso a la salud, ingresos, inseguridad alimentaria y satisfacción con la vida.
- Modelo predictivo de regresión logística para estimar la probabilidad de pobreza percibida, con 77,6 % de exactitud y AUC de 0,82.
- La insuficiencia de ingresos apareció como el predictor más fuerte de pobreza percibida, con una razón de probabilidades cercana a 13, por encima del acceso geográfico a servicios de salud.

**Herramientas:** Power BI, Power Query, R, RStudio, Python, scikit-learn y pandas.

## Informe interactivo

[Ver informe publicado en Power BI](https://app.powerbi.com/view?r=eyJrIjoiMTQ4NDE5OTQtOTJlZi00MDc1LWI1YzgtNDBmMzIyN2U0YTg0IiwidCI6IjNiOTQ0ZDlhLTEwNTEtNDY4NS1iMDlkLTlhOTVlZTJkYmQ5OSIsImMiOjR9)

## Contenido del repositorio

- `analisis-r/`: proyecto de RStudio, script cartográfico, mapas exportados e indicadores por departamento.
- `notebooks/`: notebook de Python utilizado para consolidar metadatos de variables.
- `power-bi/`: archivo editable del informe de Power BI.
- `informes/`: informe académico, presentación y declaración de uso de IA.
- `diccionario/`: diccionario consolidado de variables de la ECV 2025.

## Indicadores cartográficos

El análisis incluye cuatro visualizaciones departamentales:

1. Inseguridad alimentaria grave.
2. Dificultad de acceso a hospitales.
3. Insuficiencia de ingresos.
4. Satisfacción con la vida.

Las decisiones de clasificación, escala y paleta se documentan en [`analisis-r/README_cartografia.md`](analisis-r/README_cartografia.md).

## Reproducción del análisis

1. Descarga los microdatos de la [ECV 2025 en el catálogo del DANE](https://microdatos.dane.gov.co/index.php/catalog/905/get-microdata).
2. Descarga la cartografía departamental del [Geoportal del DANE](https://geoportal.dane.gov.co/).
3. Organiza los archivos siguiendo la estructura indicada en [`analisis-r/datos/README.md`](analisis-r/datos/README.md).
4. Abre `analisis-r/Proyecto3_ECV2025.Rproj` en RStudio.
5. Instala los paquetes `tidyverse`, `sf`, `ggplot2`, `readr`, `classInt`, `RColorBrewer`, `openxlsx` y `cowplot`.
6. Ejecuta `analisis-r/script_mapas.R` de inicio a fin.

Los cálculos se realizaron sobre la muestra sin aplicar el factor de expansión. Por ello, los resultados representan patrones observados en la muestra y no estimaciones poblacionales.

## Datos

Los microdatos originales no se incluyen en este repositorio debido a su tamaño. Deben obtenerse directamente desde las fuentes oficiales del DANE.

## Equipo

Proyecto académico desarrollado por el equipo Lugo, Nieto y Gómez.
