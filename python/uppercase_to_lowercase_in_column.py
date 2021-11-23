import pandas as pd
import os

for filename in os.listdir('.'):
    if filename.endswith(".csv") and filename.startswith("AWB"):
        data = pd.read_csv(filename)
        data['lanid'] = data['lanid'].str.islower()
        data.to_csv(filename)

# remove duplacate
for filename in os.listdir('.'):
    if filename.endswith(".csv") and filename.startswith("AWB"):
        data = pd.read_csv(filename)
        print(len(data.index))
        data_rm_dupl = data.groupby(['app', 'lanid']).agg({'login_date': 'first', 'number_login': 'first'})
        data_rm_dupl.to_csv(filename)
