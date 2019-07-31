# Voorbeelden gebruik van CBS Open Data v3 in R
# https://www.cbs.nl/nl-nl/onze-diensten/open-data
# Auteur: Jolien Oomens
# Centraal Bureau voor de Statistiek

# In dit voorbeeld worden cijfers over de opbrengst van toeristenbelasting per 
# jaar opgehaald en weergegeven in een grafiek.

library(tidyverse)
library(cbsodataR)

# Zoek de code van toeristenbelasting op in de metedata
metadata <- cbs_get_meta("84120NED")
print(metadata$BelastingenEnWettelijkePremies %>%
        filter(str_detect(Title, "Toerist")))

# Download de cijfers over toeristenbelasting en selecteer jaarcijfers
data <- cbs_get_data("84120NED", BelastingenEnWettelijkePremies = "A045081") %>%
  select(-BelastingenEnWettelijkePremies) %>%
  cbs_add_date_column() %>%
  filter(Perioden_freq == "Y")%>%
  select(-Perioden_freq)

# Plot de tijdreeks
ggplot(data, aes(x=Perioden_Date, y=OntvangenBelastingenEnWettPremies_1)) +
  geom_line() + 
  ylim(0,250)+
  labs(title = "Opbrengst toeristenbelasting per jaar", x = "",
       y = "mln euro",
       caption = "Bron: CBS")
