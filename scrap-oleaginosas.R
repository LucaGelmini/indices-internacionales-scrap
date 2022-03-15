
# WD y librerías  --------------------------------------------------------------------

setwd("./instalacion selenium r") # Inserir caminho
system("java -jar selenium-server-standalone-4.0.0-alpha-1.jar", wait = FALSE) # Declara selenium
system("chromedriver.exe", wait = FALSE) # Declara chromedriver

library(RSelenium)
library(tidyverse)
library(lubridate)
library(rvest)
library(glue)
library(dplyr) #Para calcular la variaciÃ³n mensual
library(jsonlite)
library(plotly)
library(eList)

# Abrir y maximizar link --------------------------------------------------

link = "https://www.magyp.gob.ar/sitio/areas/ss_mercados_agropecuarios/areas/granos/index.php"

#tarda unos segundos en cargar
eCaps <- list(
  chromeOptions = 
    list(prefs = list("profile.default_content_settings.popups" = 0L,
                      "download.prompt_for_download" = FALSE,
                      "directory_upgrade" = TRUE,
                      "download.default_directory" = getwd() %>% str_replace_all("/", "\\\\"))
    )
)


driver <- remoteDriver(remoteServerAddr = "localhost", 
                       browserName = "chrome",
                       extraCapabilities = eCaps) # Inicia o driver

driver$open() # Abre navegador/browser

driver$navigate(link) # Navega pelo link
driver$maxWindowSize() # Maximiza a janela do navegador


# Precios internacionales -------------------------------------------------

Sys.sleep(2)

boton_p_int <- driver$findElement(using = 'link text', value = 'Precios Internacionales')
boton_p_int$clickElement()
Sys.sleep(1)

boton_evo_p_ext <- driver$findElement(using = 'link text',
                                      value = 'Evolución de los Precios Externos')
boton_evo_p_ext$clickElement()
Sys.sleep(1)


boton_oleaginosas_years <- driver$findElement(using = 'link text', value = 'Oleaginosas (Mensual en u$s-tn)')
boton_oleaginosas_years$clickElement()
Sys.sleep(1)


oleaginosas_years <- driver$findElements(using = 'css selector',
                                             value = '#collapsee9829117d9288d8fb980211b3ad720f5 .panel-group div a')

#Hago una lista con todos los href de cada Año
table_links <- lapply(oleaginosas_years,function(year) year$getElementAttribute('href'))
table_links <- table_links[seq(1, length(table_links), 2)] #Me quedo solo con los impares porque se repiten
#Hago lo mismo que antes pero con el texto de los <a>, es decir los Años
table_links_years <- lapply(oleaginosas_years,function(year) year$getElementText())
table_links_years <- table_links_years[seq(1, length(table_links_years), 2)]


# Read html table (function)--------------------------------------------------------------


read_html_table <- function(link, Año){
  content <- read_html(link)
  tablas <- content %>% html_table(fill = T)
  first_table <- tablas[[length(tablas)]]
  first_table <- first_table[-1,]
  
  
  first_table_header <- first_table[-c(3:length(first_table)+1), ]
  
  first_table_header <- rbind(first_table_header, row3 = apply(first_table_header, 2, paste0, collapse = "-"))
  
  tabla <- (rbind(first_table_header[-c(1:3),], first_table[-c(1:4),]))
  
  names(tabla) <- as.matrix(tabla[1, ])
  tabla <- tabla[-1, ]
  tabla[] <- lapply(tabla, function(x) type.convert(as.character(x)))
  
  colnames(tabla)[1] <- 'Mes'
  
  tabla$Mes <- 1:nrow(tabla)
  
  Año <- as.integer(Año)
  
  tabla$Año <- rep.int(Año, length(tabla$Mes))
  tabla$Fecha <- lapply(tabla$Mes, function(mes) paste(Año, mes, "01", sep = "-")) %>%
    unlist %>%
    as.Date()
  return (tabla[, c(16, 1, 17, 2:15)])
}


# Loop de lectura de tablas -----------------------------------------------
toString(table_links[[5]])

lista_de_tablas <-  List(for (idx in 1:length(table_links)) read_html_table(toString(table_links[[idx]]), table_links_years[[idx]]))
  


driver$close()

