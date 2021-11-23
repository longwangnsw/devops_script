import pandas as pd
import os

i = 0
for filename in os.listdir('.'):
    if filename.endswith(".csv") and filename.startswith("AWB"):
        data = pd.read_csv(filename)
        all_lower = data['lanid'].str.islower()
        if (all_lower.all()):
            print(filename)
            i = i + 1
print(i)
