# Voorbeelden gebruik van CBS Open Data v3 in R
# https://www.cbs.nl/nl-nl/onze-diensten/open-data
# Auteur: Jolien Oomens
# Centraal Bureau voor de Statistiek

# Minimale voorbeelden van het ophalen van een tabel en metadata
# met behulp van het package cbsodataR.

library(cbsodataR)

# Downloaden van informatie over gemeente Amsterdam
data_amsterdam <- cbs_get_data("83765NED", WijkenEnBuurten = "GM1680    ")
print(data)

# Downloaden van gehele tabel (kan een halve minuut duren)
data <- cbs_get_data("83765NED")
head(data)

# Downloaden van metadata
metadata <- cbs_get_meta("83765NED")
head(metadata)
