extends Node

@onready var top_hand = $CanvasLayer/Up/Hand
@onready var top_deck = $CanvasLayer/Up/Deck/Window/HiddenField

@onready var down_hand = $CanvasLayer/Down/Hand
@onready var down_deck = $CanvasLayer/Down/Deck/Window/HiddenField

func _on_take_control_top():
	print(multiplayer.get_unique_id(), " took control of top")
	top_hand.owner_id = multiplayer.get_unique_id()
	top_hand.update_cards_hiddeness()
	top_deck.owner_id = multiplayer.get_unique_id()
	top_deck.update_cards_hiddeness()
	
func _on_take_control_down():
	print(multiplayer.get_unique_id(), " took control of bottom")
	down_hand.owner_id = multiplayer.get_unique_id()
	down_hand.update_cards_hiddeness()
	down_deck.owner_id = multiplayer.get_unique_id()
	down_deck.update_cards_hiddeness()
	
