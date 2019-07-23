"""
Voorbeelden gebruik van beta-versie CBS Open Data in Python
https://beta.opendata.cbs.nl
Auteur: Jolien Oomens
Centraal Bureau voor de Statistiek

Minimale voorbeelden van het ophalen van een tabel, het koppelen van metadata
en het filteren van data voor het downloaden.
"""

import pandas as pd
import requests

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

table_url = "https://beta.opendata.cbs.nl/OData4/CBS/83765NED"

# Downloaden van gehele tabel, duurt ongeveer 2 minuten
# target_url = table_url + "/Observations"
# Downloaden van eerste 100 rijen uit de tabel
target_url = table_url + "/Observations?$top=100"
data = get_odata(target_url)
print(data.head())

# Koppelen van metadata aan tabel
groups = get_odata(table_url + "/MeasureGroups")
codes = get_odata(table_url + "/MeasureCodes")

data = pd.merge(data, codes, left_on = "Measure", right_on = "Identifier")
data = pd.merge(data, groups, left_on = "MeasureGroupID", right_on = "ID")
print(data.head())

# Selectie downloaden van tabel
wijken_en_buurtencodes = get_odata(table_url + "/WijkenEnBuurtenCodes")
ams = wijken_en_buurtencodes[wijken_en_buurtencodes['Title'].str.contains("Amsterdam")]
print(ams[['Title','Identifier']])

target_url = table_url + "/Observations?$filter=WijkenEnBuurten eq \'GM0363    \'"
data_amsterdam = get_odata(target_url)
print(data_amsterdam.head())
