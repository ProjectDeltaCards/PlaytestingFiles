extends RichTextLabel

@export var targetFontSize = 60
@export var minFontSize = 35

signal set_sized_text_finished

@onready var parent = $".."
var initialSize

# Called when the node enters the scene tree for the first time.
func _ready():
	initialSize = parent.size
	setSizedText("[u]Human[/u] Female Beacon Pirate")

func setSizedText(newText: String):
	bbcode_enabled = true
	var fontSize = targetFontSize
	await applyFontSize(fontSize, newText)

	while (size.y > initialSize.y):
		fontSize -= 2
		if (fontSize <= minFontSize):
			break

		await applyFontSize(fontSize, newText)

	set_sized_text_finished.emit()

# Note this function assumes that the added text doesn't mess with the font size at all
func applyFontSize(size: int, text: String):
	clear()
	push_font_size(size)
	append_text(text)
	await get_tree().process_frame
#	await self.finished
