"""
Voorbeelden gebruik van CBS Open Data v3 in Python
https://www.cbs.nl/nl-nl/onze-diensten/open-data
Auteur: Jolien Oomens
Centraal Bureau voor de Statistiek

In dit voorbeeld worden gemeentegrenzen gekoppeld aan geboortecijfers om een 
thematische kaart te maken.
"""

import pandas as pd
import geopandas as gpd
import cbsodata

# Haal alle geboortecijfers op en filter op gemeenten
data = pd.DataFrame(cbsodata.get_data('83765NED', select = ['WijkenEnBuurten', 'Codering_3', 'GeboorteRelatief_25']))
data['Codering_3'] = data['Codering_3'].str.strip()

# De geodata wordt via de API van het Nationaal Georegister van PDOK opgehaald.
# Een overzicht van beschikbare data staat op https://www.pdok.nl/datasets.
geodata_url = "https://geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs?request=GetFeature&service=WFS&version=2.0.0&typeName=cbs_gemeente_2017_gegeneraliseerd&outputFormat=json"
gemeentegrenzen = gpd.read_file(geodata_url)

gemeentegrenzen = pd.merge(gemeentegrenzen, data, left_on = "statcode", right_on = "Codering_3")

p = gemeentegrenzen.plot(column='GeboorteRelatief_25', figsize = (10,8))
p.axis('off')
p.set_title("Levend geborenen per 1000 inwoners, 2017")
