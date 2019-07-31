# Voorbeelden gebruik van CBS Open Data v3 in R
# https://www.cbs.nl/nl-nl/onze-diensten/open-data
# Auteur: Jolien Oomens
# Centraal Bureau voor de Statistiek

# In dit voorbeeld worden gemeentegrenzen gekoppeld aan geboortecijfers om een 
# thematische kaart te maken.

library(cbsodataR)
library(geojsonio)
library(sp)
library(tidyverse)

# Zoek op welke data beschikbaar is
metadata <- cbs_get_meta("83765NED")
print(metadata$DataProperties$Key)

# Haal alle geboortecijfers op
data <- cbs_get_data("83765NED", select=c("WijkenEnBuurten","Codering_3","GeboorteRelatief_25")) %>%
  mutate(Codering_3 = str_trim(Codering_3))

# De geodata wordt via de API van het Nationaal Georegister van PDOK opgehaald.
# Een overzicht van beschikbare data staat op https://www.pdok.nl/datasets.
geoUrl <- "https://geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs?request=GetFeature&service=WFS&version=2.0.0&typeName=cbs_gemeente_2017_gegeneraliseerd&outputFormat=json"
fileName <- "gemeentegrenzen2017.geojson"
download.file(geoUrl, fileName)
gemeentegrenzen <- geojson_read(fileName, what = "sp")

gemeentegrenzen@data <- gemeentegrenzen@data %>% 
  left_join(data,by=c("statcode"="Codering_3"))

g <- fortify(gemeentegrenzen, region = "id")
g <- merge(g, gemeentegrenzen@data, by = "id")

ggplot(data = g) +
  geom_polygon(aes(x=long, y=lat, group = group, fill = GeboorteRelatief_25)) +
  coord_equal() +
  ggtitle("Levend geborenen per 1000 inwoners, 2017") +
  labs(fill = "", caption = "Bronnen: CBS, PDOK") + 
  theme_void()
