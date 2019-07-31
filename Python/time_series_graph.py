"""
Voorbeelden gebruik van CBS Open Data v3 in Python
https://www.cbs.nl/nl-nl/onze-diensten/open-data
Auteur: Jolien Oomens
Centraal Bureau voor de Statistiek

In dit voorbeeld worden cijfers over de opbrengst van toeristenbelasting per 
jaar opgehaald en weergegeven in een grafiek.
"""

import pandas as pd
import cbsodata

# Download data en selecteer jaarcijfers
data = pd.DataFrame(cbsodata.get_data('84120NED', filters = "BelastingenEnWettelijkePremies eq 'A045081'"))
data = data[data['Perioden'].str.match("^\d{4}$")]

# Plot een grafiek
p = data.plot(x = 'Perioden', y = 'OntvangenBelastingenEnWettPremies_1',legend = False)
p.set_title("Opbrengst toeristenbelasting per jaar")
p.set_ylim([0,250])
p.set_xlabel("")
p.set_ylabel("mln euro")
