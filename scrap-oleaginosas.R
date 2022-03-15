
# WD y librerías  --------------------------------------------------------------------

setwd("./instalacion selenium r") # Inserir caminho
system("java -jar selenium-server-standalone-4.0.0-alpha-1.jar", wait = FALSE) # Declara selenium
system("chromedriver.exe", wait = FALSE) # Declara chromedriver

library(RSelenium)
library(tidyverse)
library(lubridate)
library(rvest)
library(glue)
library(dplyr) #Para calcular la variación mensual
library(jsonlite)
library(plotly)

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

Sys.sleep(4)

boton_p_int <- driver$findElement(using = 'link text', value = 'Precios Internacionales')
boton_p_int$clickElement()

boton_evo_p_ext <- driver$findElement(using = 'link text',
                                      value = 'Evolución de los Precios Externos')
boton_evo_p_ext$clickElement()

boton_oleaginosas_years <- driver$findElement(using = 'link text', value = 'Oleaginosas (Mensual en u$s-tn)')
boton_oleaginosas_years$clickElement()

oleaginosas_years <- driver$findElements(using = 'css selector',
                                             value = '#collapsee9829117d9288d8fb980211b3ad720f5 .panel-group div a')
oleaginosas_years[[5]]$clickElement()


year_inicial = 2015

length(oleaginosas_years[1])

for (idx in 1:length(oleaginosas_years)) {
  if (idx%%2 !=0){
    oleaginosas_years[[idx]]$clickElement()
    }
  
}


