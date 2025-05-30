extends SubViewport
class_name CardRenderer

var settedSlot = "INVALID";

@export var sheetsData : Node

enum CardColor {
	Generic,
	Red,
	Orange,
	Yellow,
	Green,
	Blue,
	Purple
}

func CardColor2Light(color: CardColor) -> Color:
	match(color):
		CardColor.Red: return Color("#FF6663")
		CardColor.Orange: return Color("#FEB144")
		CardColor.Yellow: return Color("#FDFD97")
		CardColor.Green: return Color("#9EE09E")
		CardColor.Blue: return Color("#77B1C8")
		CardColor.Purple: return Color("#AE65AA")
	return Color("#D9D9DB") # Generic

func CardColor2Dark(color: CardColor) -> Color:
	match(color):
		CardColor.Red: return Color("#9A4E4F")
		CardColor.Orange: return Color("#99733F")
		CardColor.Yellow: return Color("#999969")
		CardColor.Green: return Color("#6A8B6D")
		CardColor.Blue: return Color("#567382")
		CardColor.Purple: return Color("#654867")
	return Color("#35353B") # Generic

func CardColor2String(color: CardColor) -> String:
	match(color):
		CardColor.Red: return "Red"
		CardColor.Orange: return "Orange"
		CardColor.Yellow: return "Yellow"
		CardColor.Green: return "Green"
		CardColor.Blue: return "Blue"
		CardColor.Purple: return "Purple"
	return "Generic"


# Called when the node enters the scene tree for the first time.
func _ready():
	sheetsData.connect("all_data_available", saveCards)

func saveCards():
	var i = 0
	while i < sheetsData.data.size():
		await updateCard(sheetsData.data[i])
		saveCardToFile("res://export/" + settedSlot + ".png")
		i += 1
		# break
	print("Done!")

func updateCard(card):
#	print(card)
	settedSlot = card["setted slot"] if card.has("setted slot") else card["slot"]

	$"Control/Name".setSizedText(card["name"])
	if not "\n\n" in card["icost"]:
		$"Control/Cost".text = "[right]" + "]".join(card["icost"].split("]").slice(0, 12))
		if not $"Control/Cost".text.ends_with("]"): $"Control/Cost".text += "]"
		$"Control/Cost2".text = "[right]" + "]".join(card["icost"].split("]").slice(12, 24))
	else: 
		$"Control/Cost".text = "[right]" + card["icost"].split("\n\n")[0]
		$"Control/Cost2".text = "[right]" + card["icost"].split("\n\n")[1]
	updateRangedIcon(card)
	$"Control/Type".text = card["type"]
	$"Control/SubtypeContainer/Subtype".setSizedText(card["subtype"])
	updateEffectiveness(card)
	var rules = $"Control/RulesContainer/Rules"
	rules.text = card["irules"]

	$"Control/PH".visible = card["has ph"]
	$"Control/Attack Power".text = String.num_uint64(card["attack power"])
	$"Control/Attack Power".visible = card["has ph"]
	$"Control/Health".text = String.num_uint64(card["health"])
	$"Control/Health".visible = card["has ph"]
	
	# Pick a card image 
	var image_path = card["image"]
	if len(image_path) == 0:
		var set = settedSlot.split(".")[0]
		var rest = ".".join(settedSlot.split(".").slice(1))
		image_path = set + "/" + rest + ".png"
	image_path = "res://cardarts/" + image_path 
	var texture = preload("res://textures/placeholder.png")
	if ResourceLoader.exists(image_path):
		texture = load(image_path)
	$Control/Mask/Art.texture = texture

	updateColors(card)
	await $"Control/SubtypeContainer/Subtype".set_sized_text_finished

	while not rules.is_ready():
		await get_tree().process_frame # Wait an extra few frames to make sure the rules have rendered
	await get_tree().process_frame 
	

func saveCardToFile(path):
	print("Saving to: ", path)
	return get_texture().get_image().save_png(path)
	

func updateEffectiveness(card):
	var node = $"Control/Effectiveness"
	var effectiveness = card["effectiveness"]
	var color = Color("#D9D9DB")
	if effectiveness >= 5: color = Color("#999969")
	if effectiveness >= 9: color = Color("#9A4E4F")

	node.text = String.num_uint64(effectiveness)
	node.label_settings.font_color = color

func updateRangedIcon(card):
	var node = $"Control/Range"; var node2 = $"Control/Range2"
	var status = card["melee/ranged"]

	if status == "":
		node.visible = false; node2.visible = false
		return

	node.visible = true; node2.visible = true
	node.text = "[img=220]res://textures/icons/" + status + ".png[/img]"
	node2.text = "[img=122]res://textures/icons/" + status + ".png[/img]"

func updateColors(card):
	var colors = []
	if "Entropy" in card["color calculator"]: colors.append(CardColor.Red)
	if "Unrest" in card["color calculator"]: colors.append(CardColor.Orange)
	if "Emotion" in card["color calculator"]: colors.append(CardColor.Yellow)
	if "Vitality" in card["color calculator"]: colors.append(CardColor.Green)
	if "Order" in card["color calculator"]: colors.append(CardColor.Blue)
	if "Information" in card["color calculator"]: colors.append(CardColor.Purple)
	if "Generic" in card["color calculator"]: colors.append(CardColor.Generic)

	if colors.size() == 0: colors.append(CardColor.Generic)

	updateImageColor($"Control/Color1", 1, colors[0 % colors.size()])
	updateImageColor($"Control/Color2", 2, colors[1 % colors.size()], card["renowned"])
	updateImageColor($"Control/Color3", 3, colors[2 % colors.size()])
	updateImageColor($"Control/Color4", 4, colors[3 % colors.size()])
	updateImageColor($"Control/Color5", 5, colors[4 % colors.size()])
	# AP and HT both share the color in slot 6
	updateTextColor($"Control/Attack Power", CardColor2Dark(colors[5 % colors.size()]))
	updateTextColor($"Control/Health", CardColor2Dark(colors[5 % colors.size()]))

	# Type is colored for mono cards, and uses the generic color otherwise
	updateTextColor($"Control/Type", CardColor2Dark(colors[0] if colors.size() <= 1 else CardColor.Generic))


func updateImageColor(node: Sprite2D, index: int, color: CardColor, renowned = false):
	renowned = "renowned" if renowned else ""
	node.texture = load("res://textures/" + CardColor2String(color).to_lower() + "/" + renowned + String.num_uint64(index) + ".png")

func updateTextColor(node: Label, color: Color):
	node.label_settings.font_color = color
