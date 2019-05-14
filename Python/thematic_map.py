"""
Voorbeelden gebruik van beta-versie CBS Open Data in R
https://beta.opendata.cbs.nl
Auteur: Jolien Oomens
Centraal Bureau voor de Statistiek

In dit voorbeeld worden gemeentegrenzen gekoppeld aan geboortecijfers om een 
thematische kaart te maken.
"""

import pandas as pd
import geopandas as gpd
import requests
import os

def get_odata(target_url):
    data = pd.DataFrame()
    while target_url:
        r = requests.get(target_url).json()
        data = data.append(pd.DataFrame(r['value']))
        
        if '@odata.nextLink' in r:
            target_url = r['@odata.nextLink']
        else:
            target_url = None
            
    return data

# De gemeentekaart van het CBS is te vinden op
# https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische-data
gemeentegrenzen = gpd.read_file(os.path.dirname(os.getcwd()) + "/Shapefiles/buurt_2017/gem_2017.shp")

# Zoek op welke codes bij geboortecijfers horen
table_url = "https://beta.opendata.cbs.nl/OData4/CBS/83765NED"
codes = get_odata(table_url + "/MeasureCodes")
geb = codes[codes['Title'].str.contains("Geboorte")]
print(geb[['Title','Unit','Identifier']])

target_url = table_url + "/Observations?$filter=Measure eq 'M0000173_2' and startswith(WijkenEnBuurten,'GM')"
geboorten_per_gemeente = get_odata(target_url)
geboorten_per_gemeente['WijkenEnBuurten'] = geboorten_per_gemeente['WijkenEnBuurten'].str.strip()
geboorten_per_gemeente = geboorten_per_gemeente.rename({'Value':'relatieve_geboorte'}, axis='columns')
gemeentegrenzen = pd.merge(gemeentegrenzen, geboorten_per_gemeente, left_on = "GM_CODE", right_on = "WijkenEnBuurten")

p = gemeentegrenzen.plot(column='relatieve_geboorte')
p.set_title("Levend geborenen per 1000 inwoners, 2017")
