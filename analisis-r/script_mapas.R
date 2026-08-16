# CONFIGURACIÓN ----
library(tidyverse)
library(sf)
library(ggplot2)
library(readr)
library(classInt)
library(viridis)
library(openxlsx)
library(cowplot)

# CARGA DE DATOS ----
hogares <- read_delim(
  "datos/DBF-ECV-Condiciones_vida_hogar_tenencia_bienes-2025/Condiciones de vida del hogar y tenencia de bienes.csv",
  delim = ";",
  locale = locale(encoding = "UTF-8")
)

vivienda <- read_delim(
  "datos/DBF-ECV-Datos_vivienda-2025/Datos de la vivienda.csv",
  delim = ";",
  locale = locale(encoding = "UTF-8")
)

personas <- read_delim(
  "datos/DBF-ECV-Caracteristicas_composicion_hogar-2025/Características y composición del hogar.csv",
  delim = ";",
  locale = locale(encoding = "UTF-8")
)

# CARGA DEL MAPA ----
mapa_colombia <- st_read(
  "datos/MGN2025_ADM_DPTO_POLITICO_(geojson)/MGN_ADM_DPTO_POLITICO.geojson"
)

# PREPARACIÓN DE LLAVES ----
hogares <- hogares |>
  mutate(id_clave = paste(DIRECTORIO, SECUENCIA_ENCUESTA, SECUENCIA_P, sep = "-"))

vivienda <- vivienda |>
  mutate(id_clave = paste(DIRECTORIO, SECUENCIA_ENCUESTA, SECUENCIA_P, sep = "-"))

personas <- personas |>
  mutate(id_clave = paste(DIRECTORIO, SECUENCIA_ENCUESTA, SECUENCIA_P, sep = "-"))

# Agregar departamento a hogares
hogares <- hogares |>
  left_join(
    vivienda |> select(id_clave, P1_DEPARTAMENTO),
    by = "id_clave"
  )

# Excluir hogares sin departamento
hogares_limpios <- hogares |>
  filter(!is.na(P1_DEPARTAMENTO))

# CÁLCULO DE INDICADORES POR DEPARTAMENTO ----

# Mapa 1 — Inseguridad alimentaria grave
mapa1_datos <- hogares_limpios |>
  filter(P3516S7 %in% c(1, 2)) |>
  group_by(P1_DEPARTAMENTO) |>
  summarise(
    pct_hambre = mean(P3516S7 == 1) * 100
  )

# Mapa 2 — Acceso difícil a hospital
mapa2_datos <- hogares_limpios |>
  filter(P1913S3 %in% c(1, 2, 3, 4)) |>
  group_by(P1_DEPARTAMENTO) |>
  summarise(
    pct_hospital = mean(P1913S3 %in% c(3, 4)) * 100
  )

# Mapa 3 — Ingresos insuficientes
mapa3_datos <- hogares_limpios |>
  filter(P9090 %in% c(1, 2, 3)) |>
  group_by(P1_DEPARTAMENTO) |>
  summarise(
    pct_ingresos = mean(P9090 == 1) * 100
  )

# Mapa 4 — Satisfacción con la vida (personas 15+)
mapa4_datos <- personas |>
  filter(P6040 >= 15, P1895 >= 0) |>
  left_join(
    vivienda |> select(id_clave, P1_DEPARTAMENTO),
    by = "id_clave"
  ) |>
  filter(!is.na(P1_DEPARTAMENTO)) |>
  group_by(P1_DEPARTAMENTO) |>
  summarise(
    prom_satisfaccion = mean(P1895, na.rm = TRUE)
  )

# EXPORTAR TABLAS A EXCEL ----
wb <- createWorkbook()

addWorksheet(wb, "Inseguridad_Alimentaria")
writeData(wb, "Inseguridad_Alimentaria", mapa1_datos)

addWorksheet(wb, "Acceso_Hospital")
writeData(wb, "Acceso_Hospital", mapa2_datos)

addWorksheet(wb, "Ingresos_Insuficientes")
writeData(wb, "Ingresos_Insuficientes", mapa3_datos)

addWorksheet(wb, "Satisfaccion_Vida")
writeData(wb, "Satisfaccion_Vida", mapa4_datos)

saveWorkbook(wb, "mapas/indicadores_por_departamento.xlsx", overwrite = TRUE)

# TRANSFORMAR CRS A MAGNA-SIRGAS ----
mapa_colombia <- mapa_colombia |>
  st_transform(crs = 4686)

# Verificar columna de código de departamento en el mapa
names(mapa_colombia)

# JOIN MAPA CON INDICADORES ----
mapa_colombia <- mapa_colombia |>
  mutate(cod_depto = as.numeric(dpto_ccdgo))

mapa1 <- mapa_colombia |> left_join(mapa1_datos, by = c("cod_depto" = "P1_DEPARTAMENTO"))
mapa2 <- mapa_colombia |> left_join(mapa2_datos, by = c("cod_depto" = "P1_DEPARTAMENTO"))
mapa3 <- mapa_colombia |> left_join(mapa3_datos, by = c("cod_depto" = "P1_DEPARTAMENTO"))
mapa4 <- mapa_colombia |> left_join(mapa4_datos, by = c("cod_depto" = "P1_DEPARTAMENTO"))

# TEMA BASE ----
tema_mapa <- theme_void() +
  theme(
    plot.title       = element_text(size = 14, face = "bold", hjust = 0.5, margin = margin(b = 5)),
    plot.subtitle    = element_text(size = 10, hjust = 0.5, color = "gray40", margin = margin(b = 10)),
    legend.position  = "right",
    legend.title     = element_text(size = 9),
    legend.text      = element_text(size = 8),
    plot.margin      = margin(10, 10, 10, 10),
    plot.caption     = element_text(size = 7, color = "gray50", hjust = 0),
    plot.background  = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA)
  )

# PRODUCCIÓN DE MAPAS ----

# Mapa 1 — Inseguridad alimentaria grave
breaks1 <- classIntervals(mapa1_continental$pct_hambre, n = 5, style = "jenks")$brks

grafico1 <- ggplot(mapa1_continental) +
  geom_sf(aes(fill = pct_hambre), color = "white", linewidth = 0.3) +
  geom_text(
    data = centroides_continental,
    aes(x = lon, y = lat, label = nombre_corto),
    size = 2.2, color = "black", fontface = "bold"
  ) +
  scale_fill_gradientn(
    colors   = RColorBrewer::brewer.pal(9, "YlOrRd"),
    breaks   = round(breaks1, 1),
    limits = c(2.5, 39.0),
    name     = "Porcentaje\nde hogares",
    na.value = "gray80"
  ) +
  labs(
    title    = "En estos departamentos, más hogares pasaron hambre el año pasado",
    subtitle = "Porcentaje de hogares con inseguridad alimentaria grave · ECV 2025 · DANE",
    caption  = "Nota: Análisis sobre muestra de 86.848 hogares. Clasificación: Jenks. SRC: MAGNA-SIRGAS (EPSG:4686).\nSan Andrés y Providencia no se muestra a escala por su distancia al territorio continental."
  ) +
  tema_mapa

ggsave("mapas/mapa1_inseguridad_alimentaria.png", grafico1, width = 10, height = 12, dpi = 300)

# Mapa 2 — Acceso difícil a hospital
breaks2 <- classIntervals(mapa2_continental$pct_hospital, n = 5, style = "jenks")$brks

grafico2 <- ggplot(mapa2_continental) +
  geom_sf(aes(fill = pct_hospital), color = "white", linewidth = 0.3) +
  geom_text(
    data = centroides_continental,
    aes(x = lon, y = lat, label = nombre_corto),
    size = 2.2, color = "black", fontface = "bold"
  ) +
  scale_fill_gradientn(
    colors   = RColorBrewer::brewer.pal(9, "Blues"),
    breaks   = round(breaks2, 1),
    limits   = c(0, 100),
    name     = "Porcentaje\nde hogares",
    na.value = "gray80"
  ) +
  labs(
    title    = "El lugar donde vives determina si puedes llegar a un hospital",
    subtitle = "Porcentaje de hogares con acceso difícil a hospital (más de 30 min o no existe) · ECV 2025 · DANE",
    caption  = "Nota: Análisis sobre muestra de 86.848 hogares. Clasificación: Jenks. SRC: MAGNA-SIRGAS (EPSG:4686).\nSan Andrés y Providencia no se muestra a escala por su distancia al territorio continental."
  ) +
  tema_mapa

ggsave("mapas/mapa2_acceso_hospital.png", grafico2, width = 10, height = 12, dpi = 300)

# Mapa 3 — Ingresos insuficientes
breaks3 <- classIntervals(mapa3_continental$pct_ingresos, n = 5, style = "jenks")$brks

grafico3 <- ggplot(mapa3_continental) +
  geom_sf(aes(fill = pct_ingresos), color = "white", linewidth = 0.3) +
  geom_text(
    data = centroides_continental,
    aes(x = lon, y = lat, label = nombre_corto),
    size = 2.2, color = "black", fontface = "bold"
  ) +
  scale_fill_gradientn(
    colors   = RColorBrewer::brewer.pal(9, "Purples"),
    breaks   = round(breaks3, 1),
    limits   = c(0, 100),
    name     = "Porcentaje\nde hogares",
    na.value = "gray80"
  ) +
  labs(
    title    = "En estos departamentos, los ingresos no alcanzan para lo mínimo",
    subtitle = "Porcentaje de hogares con ingresos insuficientes · ECV 2025 · DANE",
    caption  = "Nota: Análisis sobre muestra de 86.848 hogares. Clasificación: Jenks. SRC: MAGNA-SIRGAS (EPSG:4686).\nSan Andrés y Providencia no se muestra a escala por su distancia al territorio continental."
  ) +
  tema_mapa

ggsave("mapas/mapa3_ingresos_insuficientes.png", grafico3, width = 10, height = 12, dpi = 300)

# Mapa 4 — Satisfacción con la vida
breaks4 <- classIntervals(mapa4_continental$prom_satisfaccion, n = 5, style = "jenks")$brks

grafico4 <- ggplot(mapa4_continental) +
  geom_sf(aes(fill = prom_satisfaccion), color = "white", linewidth = 0.3) +
  geom_text(
    data = centroides_continental,
    aes(x = lon, y = lat, label = nombre_corto),
    size = 2.2, color = "black", fontface = "bold"
  ) +
  scale_fill_gradientn(
    colors   = RColorBrewer::brewer.pal(11, "RdYlGn"),
    breaks   = round(breaks4, 2),
    limits   = c(7.25, 8.90),
    name     = "Promedio\n(0-10)",
    na.value = "gray80"
  ) +
  labs(
    title    = "¿Cómo se siente la gente a pesar de todo?",
    subtitle = "Promedio de satisfacción con la vida · Personas de 15 años y más · ECV 2025 · DANE",
    caption  = "Nota: Análisis sobre muestra. Escala 0-10. Clasificación: Jenks. SRC: MAGNA-SIRGAS (EPSG:4686).\nSan Andrés y Providencia no se muestra a escala por su distancia al territorio continental."
  ) +
  tema_mapa

ggsave("mapas/mapa4_satisfaccion_vida.png", grafico4, width = 10, height = 12, dpi = 300)

# EXPORTAR TABLAS A EXCEL ----
wb <- createWorkbook()

addWorksheet(wb, "Inseguridad_Alimentaria")
writeData(wb, "Inseguridad_Alimentaria", mapa1_datos)

addWorksheet(wb, "Acceso_Hospital")
writeData(wb, "Acceso_Hospital", mapa2_datos)

addWorksheet(wb, "Ingresos_Insuficientes")
writeData(wb, "Ingresos_Insuficientes", mapa3_datos)

addWorksheet(wb, "Satisfaccion_Vida")
writeData(wb, "Satisfaccion_Vida", mapa4_datos)

saveWorkbook(wb, "mapas/indicadores_por_departamento.xlsx", overwrite = TRUE)