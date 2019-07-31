"""
Voorbeelden gebruik van CBS Open Data v3 in Python
https://www.cbs.nl/nl-nl/onze-diensten/open-data
Auteur: Jolien Oomens
Centraal Bureau voor de Statistiek

Minimale voorbeelden van het ophalen van een tabel, het koppelen van metadata
en het filteren van data voor het downloaden.
"""

import pandas as pd
import cbsodata

# Downloaden van gehele tabel, duurt 30 seconden
data = pd.DataFrame(cbsodata.get_data('83765NED'))
print(data.head())

# Downloaden van informatie over de gemeente Amsterdam
data_amsterdam = pd.DataFrame(cbsodata.get_data('83765NED', filters="WijkenEnBuurten eq 'GM1680    '"))

# Downloaden van metadata
metadata = pd.DataFrame(cbsodata.get_meta('83765NED', "DataProperties"))
print(metadata[['Key','Title']])
