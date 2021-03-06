#---------------------------------------------------#
# Phortes - Oi MasterDados
# Eduardo Mor� de Mattos - eduardo@geplant.com.br
# 05/03/2022
# Estat�stica Aplicada e An�lse de dados (Analytics)
#---------------------------------------------------#

# 1. Prepara��o do ambiente de trabalho-----------------

#Limpando a �rea de trabalho----
rm(list = ls(all = T))

#Diret�rio de trabalho----
setwd("C:/Users/User/Desktop/CAPACIT. DATA SCIENCE/Estat�stica Aplicada � An�lise de Dados")

#Carregando os pacotes necess�rios----
pacman::p_load(ggplot2, ggthemes, dplyr, psych, reshape2, corrgram, gridExtra, readxl)

# 2. Ingest�o de dados----------------------------------
dados<- readxl::read_excel("Vinho.xlsx", sheet = "Plan1")
#dados<- read.table("Vinho.txt", h = T, sep = "\t", dec = ",") #"\t" � o separador de texto (tabula��o)

#Ajustando a base----
str(dados)
summary(dados)

#Transformando e adicionando vari�veis----
dados$id<- rownames(dados)
dados$Qualidade<- as.factor(dados$Qualidade)
dados$Tipo<- as.factor(dados$Tipo)


# 3. An�lise explorat�ria-------------------------------

#formato longo da base----
dados.long<- reshape2::melt(dados, id.vars = c("id", "Tipo", "Qualidade"))

#Tabelas----
table(dados$Qualidade)

prop.table(table(dados$Qualidade))

prop.table(table(dados$Qualidade, dados$Tipo), 2)

round(prop.table(table(dados$Qualidade, dados$Tipo)), 2)
round(prop.table(table(dados$Qualidade, dados$Tipo)), 2)*100

#boxplots----
ggplot(dados, aes(x = Tipo, y = pH))+
  geom_boxplot()+
  stat_summary(geom = "point", col = "red", size = 3, fun = mean)+
  facet_wrap(~Qualidade)+
  labs(title = "Meu boxplot bonit�o",
       subtitle = "Acidez dos Vinhos",
       x = "",
       y = "pH",
       caption = "6463 vinhos analisados")
theme_few()


ggplot2::ggplot(dados.long, ggplot2::aes(x = Tipo, y = value, col = Tipo))+
  ggplot2::geom_boxplot()+
  ggplot2::facet_wrap(~variable, scales = "free_y")+
  ggplot2::labs(title = "Compara��o entre vinhos por tipo")


ggplot2::ggplot(dados.long, 
                ggplot2::aes(x = Qualidade, y = value, col = Tipo))+
  ggplot2::geom_boxplot()+
  ggplot2::facet_wrap(~variable, scales = "free_y")+
  ggplot2::labs(title = "Compara��o entre vinhos por classe de qualidade")


#histogramas----
p1<- ggplot2::ggplot(dados, ggplot2::aes(x = �lcool, fill = Tipo))+
  ggplot2::geom_histogram()+
  ggplot2::labs(y = "Frequ�ncia Absoluta")

p2<- ggplot2::ggplot(dados, ggplot2::aes(x = A��car, fill = Tipo))+
  ggplot2::geom_histogram()+
  ggplot2::labs(y = "Frequ�ncia Absoluta")

gridExtra::grid.arrange(p1, p2, ncol = 2)

#correla��es----
with(dados, plot(�lcool, A��car))
cor.test(dados$�lcool, dados$A��car)

corrgram::corrgram(dados[,2:12], 
                   order = T,
                   lower.panel = corrgram::panel.pts,
                   upper.panel = corrgram::panel.cor,
                   diag.panel = corrgram::panel.density)


# 4. Modelagem de dados -------------------------------

#Visualiza��o----
plot(dados$`Acidez Vol�til`, dados$pH)

#Ajuste do modelo (linear)----
mod<- lm(pH ~ `Acidez Vol�til`, data = dados)

#Verificando o ajuste----
summary(mod)

#Normalidade dos res�duos----
shapiro.test(mod$residuals)
nortest::lillie.test(mod$residuals)

#An�lise gr�fica dos res�duos----
par(mfcol = c(2,2)); plot(mod); par(mfcol = c(1,1))

#Predizendo----
dados$pred<- predict(mod, newdata = dados)

#Compara��o----
with(dados, plot(pH, pred, xlim = c(2.5, 4), ylim = c(2.5, 4)))
abline(0, 1, col = "red")
