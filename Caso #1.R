setwd("~/data")
tasas=read.csv("tasas.csv")
clientes1=read.csv("clientes1.csv")
saldos=read.csv("saldos.csv")


library(fitdistrplus)
library(corrplot)
library(dplyr)
library(readxl)
library(caret)
library(lmtest)

clientes = clientes1 %>% select(clientes, proporcion, saldoprom, consumos2m)
str(clientes)


# Parte 1

# A. Exploración y Fitting de la distribución de tasas de interéses con su interpretación

  #Exploración

hist(tasas$activamensual)
hist(tasas$pasivamensual)

head(tasas$activamensual)
mean(tasas$activamensual)
median(tasas$activamensual)

hist(clientes$consumos2m)
hist(clientes$clientes)


  #Fitting

descdist(tasas$activamensual)
descdist(tasas$activamensual,boot=1000)


  #Gamma
fitgammatasas = fitdist(tasas$activamensual,"gamma",method = "mme")

cdfcomp(fitgammatasas)
plot(fitgammatasas)
denscomp(fitgammatasas) 

  #Log Normal

fitlnormtasas = fitdist(tasas$activamensual,"lnorm",method = "mme")

cdfcomp(fitlnormtasas)
plot(fitlnormtasas)
denscomp(fitlnormtasas) 


  #Prueba para escoger numericamente a cual se parece mas
  #Akaike o AIC = Cuanto mas pequeño mejor es el fit

fitgammatasas$aic
fitlnormtasas$aic

  #La gamma es mejor fit porque tiene menor akaike (aic)

summary(fitgammatasas)


# B. Exploración y Fitting de la distribución de saldos mensuales promedio por cliente con su interpretación
  
  #Exploración

hist(saldos$x)
mean(saldos$x)
median(saldos$x)

  #Fitting

descdist(saldos$x)
descdist(saldos$x,boot=1000)

  #Log Norm

fitlnormsaldos = fitdist(saldos$x,"lnorm",method = "mme")

cdfcomp(fitlnormsaldos)
plot(fitlnormsaldos)
denscomp(fitlnormsaldos) 

  #Gamma

fitgammasaldos = fitdist(saldos$x,"gamma",method = "mme")

cdfcomp(fitgammasaldos)
plot(fitgammasaldos)
denscomp(fitgammasaldos) 

  #Prueba para escoger numericamente a cual se parece mas
  #Akaike o AIC = Cuanto mas pequeño mejor es el fit

fitlnormsaldos$aic
fitgammasaldos$aic

  #La gamma es mejor fit porque tiene menor akaike (aic)

summary(fitgammasaldos)


# C. Simulación de ingresos mensuales por interés para los próximo 3 años en un nuevo dataset
# que se llame "intereses.csv" Solo simular próximo 3 meses, la proyección es el valor esperado de cada mes


  # Simulación tasas de interes  

tasassimulacion = rgamma(10000,
                         shape = fitgammatasas$estimate["shape"],
                         rate = fitgammatasas$estimate["rate"])

  # Simulación saldos

saldossimulacion = rgamma(10000,
                          shape = fitgammasaldos$estimate["shape"],
                          rate = fitgammasaldos$estimate["rate"])

  # Ingresos por clientes 10,000 simulaciones

ingresossimulacion = tasassimulacion * saldossimulacion
ingresossimulacion

ingresospromedio = mean(ingresossimulacion)
ingresospromedio

  # Calculo ingresos totales 

clientes3meses = clientes$clientes[1:3]
meses = 1:3
ingresostotalesproyectados = ingresospromedio * clientes3meses
ingresostotalesproyectados

  # Crear dataset y exportarlo 

intereses = data.frame(
  mes = meses,
  clientes = clientes3meses,
  ingresoproyectado = ingresostotalesproyectados
)

write.csv(intereses, "intereses.csv", row.names = FALSE)


# PARTE II

# A. ¿Cuáles serían el peor escenario y mejor escenario de ingresos por intereses al 95% y 99% de confianza?


quantile(ingresossimulacion, probs = c(0.01, 0.05, 0.95, 0.99))


# B. ¿Cuál sería el escenario esperado de ingreso por intereses para un mes?

ingresospromedio

clientesmes1 = clientes$clientes[1]
clientesmes1

ingresototalmes1 = ingresospromedio * clientesmes1
ingresototalmes1

# C. El Gerente de Banca Personas presentó un análisis incluyendo un saldo 
# promedio por cliente de Q13,000. ¿Es este escenario realista?

  # Calcular percentiles 5% y 95%
p5 <- quantile(saldossimulacion, 0.05)
p95 <- quantile(saldossimulacion, 0.95)
p5
p95

  # Evaluar si 13,000 está dentro del rango realista
if (13000 > p5 & 13000 < p95) {
  print("Realista")
} else {
  print("No Realista")
}

  # Se considera que si es realista porque se encuentra entre los cuartiles 
  # 5%-95%


# PARTE III

# A. ¿Qué correlación hay entre proporción, saldoprom, consumos2m y los clientes activos? 
#¿Es positiva o negativa? Interprete. 


clientes=clientes %>% select(clientes,proporcion, saldoprom, consumos2m)
str(clientes)
correlacion=cor(clientes)
correlacion

corrplot(correlacion)
corrplot(correlacion, method = "number", order = "alphabet", bg = "gray",
         addgrid.col = "black")

  #Interpretación
 

  # Interpretación del mapa de calor de correlaciones:
  # El mapa de calor muestra una correlación casi perfecta entre las variables "clientes", "consumos2m" y "saldoprom",
  # todas con coeficientes cercanos a 1 (0.99 o 1.00), lo que indica una relación lineal directa muy fuerte entre estas variables.
  # Esto sugiere que a medida que aumenta el número de clientes, también tienden a aumentar tanto los consumos recientes como los saldos promedio.
  # En contraste, la variable "proporcion" presenta correlaciones negativas muy bajas (−0.12) con todas las demás.



# B. 	Haga un análisis de regresión multivariada con todas las variables e interprete los resultados. 
  

  # Separar en train (meses 1 al 36) y test (meses 37 al 48)

clientes1 = clientes1 %>% select(clientes, proporcion, saldoprom, consumos2m, tasaslider, ingresopordivisas, exportaciones, inflacion)
str(clientes1)

train = clientes1[1:36, ]
test = clientes1[37:48, ]

train  
test   

regresionmultivariada = lm(clientes ~ proporcion  + saldoprom + consumos2m + tasaslider + ingresopordivisas + exportaciones + inflacion, data = train)
  
  # Predicción y resumen del modelo

prediccion1 = predict(regresionmultivariada, newdata = test)
cortest1  = cor(prediccion1, test$clientes)
print(cortest1) 

summary(regresionmultivariada)

  # El valor de correlación obtenido (0.9988) indica una relación casi perfecta entre las predicciones del modelo
  # y los valores reales de test. Esto nos dice que el modelo generaliza muy bien y tiene una
  # predicción sobre el comportamiento de la variable dependiente 'clientes'.

regresionmultivariada2 = lm(clientes ~ consumos2m + tasaslider, data = train)

  # Predicción y resumen del modelo

prediccion2 = predict(regresionmultivariada2, newdata = test)
cortest2  = cor(prediccion2, test$clientes)
print(cortest2) 

summary(regresionmultivariada2)


  #Interpetación modelo mejorado 
  
  # En el modelo original, el intercepto era:
  # Estimate ≈ 481.77 con p-value ≈ 0.38 → No significativo

  # En el modelo optimizado (con menos variables), el intercepto cambió a:
  # Estimate ≈ 582.05 con p-value ≈ 0.10 → Sigue sin ser estadísticamente significativo, pero más cercano al umbral

  # El modelo optimizado conserva un R² ajustado de 0.9984, prácticamente igual al modelo original,
  # pero reduce el número de variables de 7 a solo 2. Esto lo convierte en un modelo más parsimonioso,
  # fácil de interpretar y estadísticamente robusto. Aunque tasaslider no fue significativa en este segundo modelo,
  # se justifica su inclusión por su relevancia económica. La correlación entre predicción y realidad se mantuvo en 0.9988,
  # lo que confirma su excelente capacidad de predicción sobre los datos de test.



# C. Haga las pruebas vistas en clase para validar que su modelo cumpla con Gauss Markov e interprete sus respuestas.


  # Gauss-Markov 

plot(
  regresionmultivariada2$fitted.values, regresionmultivariada2$residuals,
  xlab = 'Fitted values', ylab = 'Residuals'
)
abline(h = 0, lty = 2)  

  #Interpretación Gauss-Markov

  # El gráfico muestra que los residuos están distribuidos de forma uniforme, sin patrón claro,
  # por lo tanto, se cumple el supuesto de homocedasticidad del modelo.


  # Test homocedasticidad 

bp = bptest(regresionmultivariada2)  
print(bp)

  #Interpretación Breusch-Pagan
  
  # Según el test de Breusch-Pagan (p-value = 0.076), no se rechaza la hipótesis nula de homocedasticidad.
  # Por lo tanto, se concluye que los errores tienen varianza constante y el modelo cumple con este supuesto de Gauss-Markov.


  # Test Shapiro–Wilk

sw = shapiro.test(resid(regresionmultivariada2))
print(sw)


  #Interpretación Shapiro-Wilk

  # Según el test de Shapiro-Wilk (p-value = 0.9071), los residuos del modelo siguen una distribución normal lo cúal es positivo.
  # Por lo tanto, se cumple el supuesto de normalidad para los errores.


  # Test Durbin–Watson 

dw = dwtest(regresionmultivariada2)
print(dw)

  #Interpretación Durbin-Watson

  # El test de Durbin-Watson dio un p-value de 0.7288 y un estadístico DW = 2.3169,
  # lo que indica que no hay autocorrelación positiva de los errores.
  # Por lo tanto, se cumple el supuesto de independencia en el modelo.


# D. Use su mejor modelo para predecir los datos de Test. Calcule el accuracy del modelo e interprételo. 


regresionmultivariada2 = lm(clientes ~ consumos2m + tasaslider, data = train)

  # Predicciones en el set de prueba

predicciones_finales = predict(regresionmultivariada2, newdata = test)

  # Error absoluto medio (MAE)

mae = mean(abs(predicciones_finales - test$clientes))

  # Accuracy como proporción de acierto

accuracy = 1 - (mae / mean(test$clientes))

  # Mostrar resultados

cat("Error absoluto medio (MAE):", round(mae, 2), "\n")
cat("Accuracy del modelo:", round(accuracy * 100, 2), "%\n")


  #Interpretación final 

  # El modelo alcanzó un accuracy del 99.33% Aunque este valor es elevado,
  # el resultado está respaldada por la alta correlación entre 'consumos2m' y 'clientes',
  # el cumplimiento de todos los supuestos estadísticos del modelo (normalidad, homocedasticidad e independencia),

