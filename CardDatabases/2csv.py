import os
import pandas as pd

# Define function to replace commas with unicode equivalents
def replace_commas(cell):
	if isinstance(cell, str): return cell.replace(',', '\u066B').replace("\n", "\\n")
	return cell

filelist = os.listdir(os.getcwd())
for filename in filelist:
	if filename.endswith('.xlsx') or filename.endswith('.xls'):        
		df = pd.read_excel(filename)
		df = df.rename(columns={"Effectiveness (0-4 = common, 5-8 = uncommon, 9-10 = rare)": "Effectiveness"})
		df = df.applymap(replace_commas)
		df.to_csv(f"{filename}.csv", index=None, header=True)
	
		replaced = ""
		with open(f"{filename}.csv", "r") as f:
			replaced = f.read().replace("Unnamed: ", "u")
		with open(f"{filename}.csv", "w") as f:
			f.write(replaced)

