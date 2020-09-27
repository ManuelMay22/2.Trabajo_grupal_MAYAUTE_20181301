library(rio)
library(sp)
library(geojsonio)
library(rgdal)
library(htmltab)
library(jsonlite) 
library(stringr)
library(readr)
library(magrittr)

##Limpieza de base de datos
#####I. Densidad de doctores por 1000 personas
#1. Scraping de densidad de doctores por 1000 personas:

#1.1. Trayendo la base de datos:

linkcia="https://www.cia.gov/library/publications/the-world-factbook/fields/359.html"
linkpathcia='//*[@id="fieldListing"]'

doctors = htmltab(doc = linkcia, which =linkpathcia) 

#1.2. Guardando base de datos sucia:
write.csv(doctors, "doctors.csv", row.names = FALSE)

#2. Renombrando columnas para mejor manejo y claridad de datos:
names(doctors)=c("Country", "doctors_density")



#3. Limpiando base de datos:
doctors$doctors_density=parse_number(doctors$doctors_density)

#4. Revisando si hay datos perdidos:
doctors[!complete.cases(doctors),]

#4.1. Eliminando valores perdidos:
doctors=doctors[!doctors$Country=="Niue",]
doctors=doctors[!doctors$Country=="Micronesia, Federated States of",]
doctors=doctors[!doctors$Country=="Northern Mariana Islands",]
doctors=doctors[!doctors$Country=="Wallis and Futuna",]


#4. Guardando base de datos limpia:
write.csv(doctors, "doctors_limpia.csv", row.names = FALSE)



####II. Nr de enfermeros:
#1. Trayendo base de datos de 
#https://apps.who.int/gho/data/node.main.HWFGRP_0040?lang=en

##Como la pagina permite descargar la data en formato csv, se trae directamente de
##github

lkCSV2="https://raw.githubusercontent.com/ManuelMay22/2.Trabajo_grupal_MAYAUTE_20181301/master/enfermeros.csv"
enfermeros=import(lkCSV2)

##2. cambiando nombre a columnas:

names(enfermeros)=c("Country", "Year", "nursing_density")

##3.Eliminando columnas innecesarias:

enfermeros[,c(2)]=NULL

##4. Estandarizando los valores:
###Como la data anterior estaba en razon a 1000 personas, hay que transformar esta
## ya que está en base a 10 000 personas 

enfermeros$nursing_density=as.numeric(enfermeros$nursing_density)
enfermeros$nursing_density=(enfermeros$nursing_density)/10


#5. Revisando si hay datos perdidos:
enfermeros[!complete.cases(enfermeros),]

#5.1. Eliminando datos perdidos:
enfermeros=enfermeros[-c(88),]

#6. Guardando base de datos limpia:
write.csv(enfermeros, "enfermeros_limpia.csv", row.names = FALSE)



#III.Merge de datos:
#1. Juntando datos:
density_final_limpia=merge(doctors, enfermeros, by.x='Country', by.y='Country')


#2. Revisando si hay datos perdidos:

density_final_limpia[!complete.cases(density_final_limpia),]

#6. Guardando base de datos final limpia:
write.csv(density_final_limpia, "data_final_limpia.csv", row.names = FALSE)
