class_name Field
extends MarginContainer


@onready var card_drop_area_right: Area2D = $CardDropAreaRight
@onready var card_drop_area_left: Area2D = $CardDropAreaLeft
@onready var cards_holder = get_node_or_null("CardsHolder")


func _ready():
	$Label.text = name
	
	if cards_holder: ready_cards()
			
func ready_cards():
	print("Holder: ", cards_holder)
	for child in cards_holder.get_children():
		var card := child as Card
		card.home_field = self
		card_enter(card)


func highlight():
	modulate = Color.RED
	
func unhighlight():
	modulate = Color.WHITE

func return_card_starting_position(card: Card):
	card.reparent(cards_holder)
	cards_holder.move_child(card, card.index)

func card_enter(card: Card):
	print(card, " entered ", self)
	pass
	
func card_exit(card: Card):
	print(card, " exited ", self)
	pass

func set_new_card(card: Card):
	card_reposition(card)
	card.home_field = self


func card_reposition(card: Card):
	var field_areas = card.drop_point_detector.get_overlapping_areas()
	var cards_areas = card.card_detector.get_overlapping_areas()
	var index: int = 0
	
	if cards_areas.is_empty():
		print(field_areas.has(card_drop_area_left))
		if field_areas.has(card_drop_area_right):
			index = cards_holder.get_children().size()
	elif cards_areas.size() == 1:
		if field_areas.has(card_drop_area_left):
			index = cards_areas[0].get_parent().get_index()
		else:
			index = cards_areas[0].get_parent().get_index() + 1
	else:
		index = cards_areas[0].get_parent().get_index()
		if index > cards_areas[1].get_parent().get_index():
			index = cards_areas[1].get_parent().get_index()
		
		index += 1

	card.parent_changed.connect(_on_parent_changed.bind(card))
	card.set_parent_synced(cards_holder, index)
	
func _on_parent_changed(parent, card):
	card_enter(card)
	card.parent_changed.disconnect(self._on_parent_changed)
