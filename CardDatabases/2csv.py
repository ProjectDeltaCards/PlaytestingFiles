import os, re
import pandas as pd
from pathlib import Path

# From: https://gist.github.com/davidtheclark/5521432
def dumb_to_smart_quotes(string):
	"""Takes a string and returns it with dumb quotes, single and double,
	replaced by smart quotes. Accounts for the possibility of HTML tags
	within the string."""

	# Find dumb double quotes coming directly after letters or punctuation,
	# and replace them with right double quotes.
	string = re.sub(r'([a-zA-Z0-9.,?!;:\'\"])"', r'\1”', string)
	# Find any remaining dumb double quotes and replace them with
	# left double quotes.
	string = string.replace('"', '“')
	# Reverse: Find any SMART quotes that have been (mistakenly) placed around HTML
	# attributes (following =) and replace them with dumb quotes.
	string = re.sub(r'=“([^”]*)”', r'="\1"', string)
	# Follow the same process with dumb/smart single quotes
	string = re.sub(r"([a-zA-Z0-9.,?!;:\'])'", r'\1’', string)
	string = string.replace("'", '‘')
	string = re.sub(r"=‘([^’]*)’", r"='\1'", string)
	return string

# Define function to replace commas with unicode equivalents
def replace_commas(cell):
	if isinstance(cell, str): return cell.replace(',', '\u066B').replace("\n", "\\n")
	return cell

def replace_quotes(cell):
	if isinstance(cell, str): return dumb_to_smart_quotes(cell)
	return cell

filelist = os.listdir(os.getcwd())
for filename in filelist:
	if filename.endswith('.xlsx') or filename.endswith('.xls'):
		csvfile = Path(filename).with_suffix(".csv")

		df = pd.read_excel(filename)
		df = df.rename(columns={"Effectiveness (0-4 = common, 5-8 = uncommon, 9-10 = rare)": "Effectiveness"})
		df = df.applymap(replace_commas)
		df = df.applymap(replace_quotes)
		df.to_csv(csvfile, index=None, header=True)

		replaced = ""
		with open(csvfile, "r") as f:
			replaced = f.read().replace("Unnamed: ", "u")
		with open(csvfile, "w") as f:
			f.write(replaced)

