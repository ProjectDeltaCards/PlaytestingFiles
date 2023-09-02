extends Label

@export var targetFontSize = 60
@export var minFontSize = 35

var initialSize

# Called when the node enters the scene tree for the first time.
func _ready():
	initialSize = size
#	setSizedText("L.O.K.I.O, Logistics AI")
	setSizedText("L.O.K.I.O, Logistics Artificial Intelligence")

func setSizedText(newText: String):
	text = newText
	label_settings.font_size = 60

	while (get_line_count() > get_visible_line_count() || size.y > initialSize.y):
		label_settings.font_size -= 2
		if (label_settings.font_size <= minFontSize):
			break
