extends CardRenderer
func saveCards(): pass # Disable Saving Cards to File



@export var card_data: Dictionary

func _enter_tree() -> void:
	sheetsData = get_tree().root.get_node("/root/CardData")
	sheetsData.connect("all_data_available", self._sheet_data_ready)
	
func _sheet_data_ready():
	updateCard(CardData.data[0])

func updateCard(card):
	card_data = card
	
	super.updateCard(card)
