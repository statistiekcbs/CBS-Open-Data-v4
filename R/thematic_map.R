# Voorbeelden gebruik van beta-versie CBS Open Data in R
# https://beta.opendata.cbs.nl
# Auteur: Jolien Oomens
# Centraal Bureau voor de Statistiek

# In dit voorbeeld worden gemeentegrenzen gekoppeld aan geboortecijfers om een 
# thematische kaart te maken.

library(tidyverse)
library(jsonlite)
library(sf)

get_odata <- function(targetUrl) {
  response <- fromJSON(url(targetUrl))
  data <- response$value
  targetUrl <- response[["@odata.nextLink"]]
  
  while(!is.null(targetUrl)){
    response <- fromJSON(url(targetUrl))
    data <- bind_rows(data,response$value)
    targetUrl <- response[["@odata.nextLink"]]
  }
  return(data)
}

# De gemeentekaart van het CBS is te vinden op
# https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische-data
gemeentegrenzen <- read_sf("~/Shapefiles/buurt_2017/gem_2017.shp")

# Zoek op welke codes bij geboortecijfers horen
tableUrl <- "https://beta.opendata.cbs.nl/OData4/CBS/83765NED"
codes <- get_odata(paste0(tableUrl,"/MeasureCodes"))
codes %>% filter(str_detect(Title,"Geboorte"))

targetUrl <- paste0(tableUrl,"/Observations?$filter=Measure eq \'M0000173_2\' and startswith(WijkenEnBuurten,\'GM\')")

geboorten_per_gemeente <- get_odata(targetUrl) %>%
  mutate(WijkenEnBuurten = str_trim(WijkenEnBuurten)) %>%
  rename(relatieve_geboorte = Value)

gemeentegrenzen <- gemeentegrenzen %>%
  left_join(geboorten_per_gemeente,by=c("GM_CODE"="WijkenEnBuurten"))

ggplot(data = gemeentegrenzen) +
  geom_sf(aes(fill = relatieve_geboorte)) +
  ggtitle("Levend geborenen per 1000 inwoners, 2017") +
  theme(legend.title = element_blank())
