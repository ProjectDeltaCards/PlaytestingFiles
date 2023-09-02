extends Node

var json = JSON.new()
var data = null
var processed = 0
@export var sheets : PackedStringArray

signal new_data_available
signal all_data_available

# Called when the node enters the scene tree for the first time.
func _ready():
	for sheet in sheets:
		if "http" in sheet:
			var http = HTTPRequest.new()
			add_child(http)
			
			http.connect("request_completed", _on_request_completed)
			
			print(sheet)
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
		end = line.find("\",", start)
		if end < 0: end = line.find(",", start)
		
		data.append(line.substr(start, end-start).lstrip("\",").strip_edges())
		start = end + 1
		
	return data
	
func processCards(indata):
	var outdata = []
	for card in indata:
		if card == {}: continue
		if card["slot"].is_empty(): continue
		if card["slot"] in ["R", "U", "C"]: continue
		if not card.has("has ph"): continue
		
		card["has ph"] = card["has ph"] == "True"
		card["effectiveness"] = card["effectiveness"].to_int()
		card["attack power"] = card["attack power"].to_int()
		card["health"] = card["health"].to_int()
		card["name size"] = card["name size"].to_int()
		card["subtype size"] = card["subtype size"].to_int()
		card["renowned"] = "R." in card["type"] or card["type"] == "Commander"
		
		card["subtype"] = card["subtype"].replace("<", "[").replace(">", "]")
		card["iconified cost"] = card["iconified cost"].replace("\\n", "\n")
		card["icost"] = card["iconified cost"]
		card["iconified rules"] = card["iconified rules"].replace("\\n", "\n").replace("\"\"", "\"")
		card["irules"] = card["iconified rules"]
		
		if not card.has("setted slot"): card["setted slot"] = "err_" + card["slot"]
		
		outdata.append(card)
	return outdata
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_dt):
	if processed == sheets.size():
		processed = 0
		all_data_available.emit()
#		print(data)
		var f = FileAccess.open("res://export/res.json", FileAccess.WRITE)
		f.store_string(json.stringify(data))
		f.close()
	pass
