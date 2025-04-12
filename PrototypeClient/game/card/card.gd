class_name Card
extends MultiplayerControl


@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label
@onready var name_label: Label = %NameLabel
@onready var state_machine: CardStateMachine = $CardStateMachine
@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_detector: Area2D = $CardsDetector
@onready var card_back : Sprite2D = $CardBack
@onready var home_field: Field

var index: int = 0
const ATTACH_OFFSET = Vector2(0, 30)


func _ready():
	name_label.text = name


func _input(event):
	state_machine.on_input(event)


func _on_gui_input(event):
	state_machine.on_gui_input(event)


func _on_mouse_entered():
	state_machine.on_mouse_entered()


func _on_mouse_exited():
	state_machine.on_mouse_exited()

	
func reveal():
	card_back.hide()
	
func shroud():
	card_back.show()
	
func attach_card(card: Card):
	var child_cards = card.get_children().filter(func(c): return c is Card)
	if !child_cards.is_empty():
		child_cards[0].attach_card(card)
		return
		
	card.parent_changed.connect(_on_parent_changed.bind(card))
	card.set_parent_synced(self)
	
func _on_parent_changed(parent, card):
	card.set_position_synced(ATTACH_OFFSET)
	card.parent_changed.disconnect(_on_parent_changed)
