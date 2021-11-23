import pandas as pd
import os

for filename in os.listdir('.'):
    if filename.endswith(".csv") and filename.startswith("AWB"):
        data = pd.read_csv(filename)
        data['lanid'] = data['lanid'].str.islower()
        data.to_csv(filename)
