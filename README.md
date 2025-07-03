# 📈 Predicción de Clientes Activos e Ingresos por Interés – Modelo de Regresión Multivariada

Este proyecto fue desarrollado como parte del curso **Data Science for Finance** de la Universidad Francisco Marroquín. El objetivo principal fue construir un modelo predictivo para estimar la cantidad de clientes activos mensuales en una institución financiera, así como proyectar sus ingresos mensuales por intereses.

---

## 🧾 Descripción del Proyecto

Se analizaron bases de datos históricos que incluyen tasas de interés activas, saldos promedio por cliente y variables macroeconómicas como:

- Tasa líder
- Ingreso por divisas
- Exportaciones FOB
- Inflación mensual

A través de un enfoque de análisis exploratorio, ajuste de distribuciones, simulación estocástica y modelado predictivo, se construyó una solución completa y robusta que incluye:

- Ajuste de distribuciones a tasas y saldos con modelos **gamma** y **log-normal**
- Simulación de ingresos por interés usando Monte Carlo
- Regresión lineal multivariada
- Evaluación de escenarios y validación de supuestos bajo el teorema de Gauss-Markov

---

## 📂 Archivos Incluidos

| Archivo              | Descripción                                                                 |
|----------------------|------------------------------------------------------------------------------|
| `clientes1.csv`      | Dataset con variables mensuales (clientes, consumos, tasas, exportaciones) |
| `saldos.csv`         | Muestra de saldos mensuales promedio por cliente                            |
| `tasas.csv`          | Tasas activas y pasivas mensuales históricas                                |
| `intereses.csv`      | 📦 Generado por simulación: ingresos proyectados por interés (3 meses)      |
| `informe.pdf`        | Informe académico oficial entregado (resumen y resultados del caso)         |
| `modelo_regresion.R` | Script completo en R con análisis, simulaciones, regresión y validación     |

---

## 🔍 Análisis y Resultados

### 1. Exploración y Fitting de Distribuciones

Se identificó que la **distribución gamma** ajusta mejor los datos de tasas y saldos, basado en el criterio de Akaike (AIC). Posteriormente se simularon 10,000 observaciones para cada variable.

### 2. Simulación de Ingresos por Interés

Se calcularon ingresos esperados multiplicando tasas simuladas por saldos simulados, y luego por el número proyectado de clientes en los siguientes 3 meses. El archivo `intereses.csv` contiene estos resultados.

### 3. Escenarios de Ingreso

Se determinaron intervalos de confianza al 95% y 99% para estimar escenarios optimistas y pesimistas. Además, se evaluó si un saldo promedio de Q13,000 era estadísticamente realista (y se confirmó que sí lo era).

### 4. Modelo de Regresión Multivariada

Se construyeron dos modelos:

- **Modelo completo** con 7 variables
- **Modelo optimizado** con solo `consumos2m` y `tasalider`, manteniendo un R² ajustado de **0.9984**

El modelo mostró un **MAE de 243.61** y una **precisión del 99.33%**, con cumplimiento total de los supuestos clásicos (homocedasticidad, normalidad e independencia de errores).

---

## 🧪 Validación del Modelo

Se realizaron las siguientes pruebas estadísticas:

- ✅ **Breusch-Pagan**: No se rechaza homocedasticidad (p = 0.076)
- ✅ **Shapiro-Wilk**: Residuos normales (p = 0.9071)
- ✅ **Durbin-Watson**: Sin autocorrelación de errores (DW = 2.3169, p = 0.7288)

---

## 📊 Herramientas y Paquetes en R

- `fitdistrplus` – Ajuste de distribuciones
- `caret`, `lmtest` – Modelado y pruebas estadísticas
- `corrplot` – Visualización de correlaciones
- `dplyr` – Manipulación de datos

---

## 👨‍💻 Autores

- **Estuardo García** 


**Curso:** Data Science for Finance  
**Universidad Francisco Marroquín (UFM)**  
**Catedrático:** María Isabel Avila Rigalt  
**Auxiliar:** Wilder de Jesús Villeda

---


