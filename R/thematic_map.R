# Voorbeelden gebruik van beta-versie CBS Open Data in R
# https://beta.opendata.cbs.nl
# Auteur: Jolien Oomens
# Centraal Bureau voor de Statistiek

# In dit voorbeeld worden gemeentegrenzen gekoppeld aan geboortecijfers om een 
# thematische kaart te maken.

library(jsonlite)
library(geojsonio)
library(tidyverse)
library(sp)

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

# De geodata wordt via de API van het Nationaal Georegister van PDOK opgehaald.
# Een overzicht van beschikbare data staat op https://www.pdok.nl/datasets.
geoUrl <- "https://geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs?request=GetFeature&service=WFS&version=2.0.0&typeName=cbs_gemeente_2017_gegeneraliseerd&outputFormat=json"
fileName <- "gemeentegrenzen2017.geojson"
download.file(geoUrl, fileName)
gemeentegrenzen <- geojson_read(fileName, what = "sp")

# Zoek op welke codes bij geboortecijfers horen
tableUrl <- "https://beta.opendata.cbs.nl/OData4/CBS/83765NED"
codes <- get_odata(paste0(tableUrl,"/MeasureCodes"))
codes %>% filter(str_detect(Title,"Geboorte"))

targetUrl <- paste0(tableUrl,"/Observations?$filter=Measure eq \'M0000173_2\' and startswith(WijkenEnBuurten,\'GM\')")

geboorten_per_gemeente <- get_odata(targetUrl) %>%
  mutate(WijkenEnBuurten = str_trim(WijkenEnBuurten)) %>%
  rename(relatieve_geboorte = Value)

gemeentegrenzen@data <- gemeentegrenzen@data %>%
  left_join(geboorten_per_gemeente,by=c("statcode"="WijkenEnBuurten"))

g <- fortify(gemeentegrenzen, region = "id")
gemeentegrenzenDF <- merge(g, gemeentegrenzen@data, by = "id")

ggplot(data = gemeentegrenzenDF) +
  geom_polygon(aes(x=long, y=lat, group = group, fill = relatieve_geboorte)) +
  coord_equal()+
  ggtitle("Levend geborenen per 1000 inwoners, 2017") +
  theme_void()
