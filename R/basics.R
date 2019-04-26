# Voorbeelden gebruik van beta-versie CBS Open Data in R
# https://beta.opendata.cbs.nl
# Auteur: Jolien Oomens
# Centraal Bureau voor de Statistiek

# Minimale voorbeelden van het ophalen van een tabel, het koppelen van metadata
# en het filteren van data voor het downloaden.

library(tidyverse)
library(jsonlite)

get_odata <- function(targetUrl) {
  data <- data.frame()
  
  while(!is.null(targetUrl)){
    response <- fromJSON(url(targetUrl))
    data <- bind_rows(data,response$value)
    targetUrl <- response[["@odata.nextLink"]]
  }
  return(data)
}

tableUrl <- "https://beta.opendata.cbs.nl/OData4/CBS/83765NED"

# Downloaden van gehele tabel
targetUrl <- paste0(tableUrl,"/Observations")
data <- get_odata(targetUrl)
head(data)

# Koppelen van metadata aan tabel
groups <- get_odata(paste0(tableUrl,"/MeasureGroups"))
codes <- get_odata(paste0(tableUrl,"/MeasureCodes"))

data <- data %>%
  left_join(codes, by=c("Measure"="Identifier"))%>%
  left_join(groups, by=c("MeasureGroupID"="ID"))

# Gedeelte downloaden van tabel
wijken_en_buurtencodes <- get_odata(paste0(tableUrl,"/WijkenEnBuurtenCodes"))
wijken_en_buurtencodes %>% filter(str_detect(Title, "Amsterdam"))

targetUrl <- paste0(tableUrl,"/Observations?$filter=WijkenEnBuurten eq \'GM0363    \'")
data_amsterdam <- get_odata(targetUrl)
