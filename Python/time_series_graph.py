"""
Voorbeelden gebruik van beta-versie CBS Open Data in R
https://beta-odata4.cbs.nl
Auteur: Jolien Oomens
Centraal Bureau voor de Statistiek

In dit voorbeeld worden cijfers over de opbrengst van toeristenbelasting per 
jaar opgehaald, bewerkt en weergegeven in een grafiek.
"""

import pandas as pd
import requests
import datetime

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

# Bekijk welke metadata beschikbaar is
table_url = "https://beta-odata4.cbs.nl/CBS/84120NED"
print(get_odata(table_url))

# Zoek de code van toeristenbelasting op
belastingcodes = get_odata(table_url + "/BelastingenEnWettelijkePremiesCodes")
print(belastingcodes[belastingcodes['Title'].str.contains("Toerist")])

# Haal de data op
target_url = table_url + "/Observations?$filter=BelastingenEnWettelijkePremies eq 'A045081'"
data = get_odata(target_url)

# Verwijder overbodige kolommen
data = data[['Perioden','Value']]

""" 
Deze functie voegt drie kolommen toe aan het dataframe: year, frequency en
date. Standaard wordt de begindatum van de periode toegevoegd, zoals 01-03-2019
bij de periode 2019KW01.
"""
def cbs_add_date_column(data, period_name = "Perioden"):
    if not period_name in list(data):
        print("No time dimension found called " + period_name)
        return data
    
    regex = r'(\d{4})([A-Z]{2})(\d{2})'
    data[['year','frequency','count']] = data[period_name].str.extract(regex)
    
    freq_dict = {'JJ': 'Y', 'KW': 'Q', 'MM': 'M'}
    data = data.replace({'frequency': freq_dict})
    
     # Converteert van het CBS-formaat voor perioden naar een datetime.
    def convert_cbs_period(row):
        if(row['frequency'] == 'Y'):
            return datetime.datetime(int(row['year']),1,1)
        elif(row['frequency'] == 'M'):
            return datetime.datetime(int(row['year']),int(row['count']),1)
        elif(row['frequency'] == 'Q'):
            return datetime.datetime(int(row['year']),int(row['count'])*3-2,1)
        else:
            return None
        
    data['date'] = data.apply(convert_cbs_period, axis = 1)
    return data

data = cbs_add_date_column(data)

# Selecteer jaarcijfers en plot een grafiek
jaarcijfers = data[data['frequency'] == 'Y']

p = jaarcijfers.plot(x = 'date', y = 'Value',legend = False)
p.set_title("Opbrengst toeristenbelasting per jaar")
p.set_ylim([0,300])
p.set_xlabel("")
p.set_ylabel("mln euro")