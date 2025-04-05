extends Node
class_name SheetsData

var json = JSON.new()
var data = null
var processed = 0
@export var sheets : PackedStringArray

signal new_data_available
signal all_data_available

func _ready():
	for sheet in sheets:
		if "http" in sheet:
			var http = HTTPRequest.new()
			add_child(http)
			
			http.connect("request_completed", _on_request_completed)
			
			http.request(sheet)
		else:
			var file = FileAccess.open(sheet, FileAccess.READ)
			
			if data == null: data = []
			data.append_array(processCards(parseRawData(file.get_as_text())))
			processed += 1
			new_data_available.emit()
			

func _on_request_completed(_result, response_code, _headers, body):
	print(response_code)
	
	if data == null: data = []
	data.append_array(processCards(parseRawData(body.get_string_from_utf8())))
	processed += 1
	new_data_available.emit()
	
func parseRawData(rawData):
	var wholeData = []
	
	var lines = rawData.split("\n")
	var names = parseCSVLine(lines[0]).map(func(name): return name.replace(" (0-4 = common, 5-8 = uncommon, 9-10 = rare)", "").to_lower())
	for i in range(1, lines.size()):
		var data = {}
		var line = parseCSVLine(lines[i])
		for l in range(0, line.size()):
			data[names[l]] = line[l].lstrip("\"").rstrip("\"")
		wholeData.append(data)
	
	return wholeData
	
func parseCSVLine(line: String):
	var data = []
	line = line + "," # Add an extra comma at the end of the line to fix the last column getting dropped bug!
	var first = true
	var start = 0
	var end = start
	while start < line.length() and (first or start > 0):
		first = false
		if line[start] == '"':
			end = line.find("\",", start)
		else: end = line.find(",", start)
		
		data.append(line.substr(start, end-start).lstrip("\",").strip_edges())
		if line[start] == '"': end += 1
		start = end + 1
		
	return data
	
func processCards(indata):
	var costRegex = RegEx.new()
	costRegex.compile("([NUMVOIXZG+_](\\/[NUMVOI])?|1?[0-9])")
	var symbolExtractRegex = RegEx.new()
	symbolExtractRegex.compile("(\\[([NUMVOITQXZG+_](\\/[NUMVOI])?|1?[0-9])\\])")
	var parenthesizedExtractRegex = RegEx.new()
	parenthesizedExtractRegex.compile("(\\([\\s\\S]*?\\))")
	var referenceExtractRegex = RegEx.new()
	referenceExtractRegex.compile("`([^`]*?)`")
	
	var outdata = []
	for card in indata:
		if card == {}: continue
		if card["slot"].is_empty(): continue
		if card["slot"] in ["R", "U", "C"]: continue
		if card["slot"] == card["name"]: continue # Skip over any dummy slots!
		# if not card.has("has ph"): card["has ph"] = "False"
		
		card["has ph"] = !card["health"].strip_edges().is_empty()
		card["effectiveness"] = card["effectiveness"].to_int()
		card["attack power"] = card["attack power"].to_int()
		card["health"] = card["health"].to_int()
		#card["name size"] = card["name size"].to_int()
		#card["subtype size"] = card["subtype size"].to_int()
		card["renowned"] = "R." in card["type"] or card["type"] == "Commander"
		
		card["name"] = card["name"].replace("\u066B", ",")
		card["subtype"] = card["subtype"].replace("<", "[").replace(">", "]")
		card["iconified cost"] = costRegex.sub(card["cost"], "[img=119]res://textures/icons/$0.png[/img]\n", true).strip_edges()
		card["iconified cost"] = card["iconified cost"].replace("\\n", "\n")
		card["icost"] = card["iconified cost"]

		card["iconified rules"] = referenceExtractRegex.sub(
			parenthesizedExtractRegex.sub(
				symbolExtractRegex.sub(card["rules"], "[img=45]res://textures/icons/$2.png[/img]", true).replace("--","—").replace("->","•").replace("~@",\
					"<i>" + card["name"].split(",")[0] + "</i>"\
				).replace("~", "<i>" + card["name"] + "</i>"),\
			"[i][color=#34343A]$0[/color][/i]", true),\
			"<i>$1</i>", true
		).replace("<", "[").replace(">", "]").replace("[/p][p]", "[font_size=15]\n\n[/font_size]").replace("[br/]", "\n")
		card["iconified rules"] = card["iconified rules"].replace("\\n", "[font_size=15]\n\n[/font_size]").replace("\"\"", "\"").replace("\u066B", ",")

		if card["iconified rules"].is_empty():
			card["iconified rules"] = "[i][color=#34343A]" + card["flavor"] + "[/color][/i]"
		card["irules"] = card["iconified rules"]	

		if not card.has("color calculator") or "#NAME" in card["color calculator"]:
			card["color calculator"] = ""
			if "N" in card["cost"]: card["color calculator"] += " Entropy"
			if "U" in card["cost"]: card["color calculator"] += " Unrest"
			if "M" in card["cost"]: card["color calculator"] += " Emotion"
			if "V" in card["cost"]: card["color calculator"] += " Vitality"
			if "O" in card["cost"]: card["color calculator"] += " Order"
			if "I" in card["cost"]: card["color calculator"] += " Information"
		
		if not card.has("color") or "#NAME" in card["color"]:
			var colors = card["color calculator"].strip_edges().split(" ")
			if colors.size() == 1: card["color"] = colors[0]
			else: card["color"] = "Multicolor"
		
		if not card.has("setted slot"):
			if "." in card["slot"]: card["setted slot"] = card["slot"]
			else: card["setted slot"] = "ERR." + card["slot"]
		
		outdata.append(card)
	return outdata
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	if processed == sheets.size():
		processed = 0
		all_data_available.emit()
#		print(data)
		#var f = FileAccess.open("res://export/res.json", FileAccess.WRITE)
		#f.store_string(json.stringify(data))
		#f.close()
