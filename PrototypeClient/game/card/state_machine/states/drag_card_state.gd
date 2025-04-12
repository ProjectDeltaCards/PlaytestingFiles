extends CardState

var currently_hovered_field = null

func _enter():
	set_multiplayer_authority(multiplayer.get_unique_id())
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	card.color_rect.color = Color.BLUE
	card.label.text = "DRAG"
	
	card.index = card.get_index()
	
	var canvas_layer := get_tree().get_first_node_in_group("fields")
	if canvas_layer:
		card.set_parent_synced(canvas_layer)
		
	
func _exit():
	process_mode = Node.PROCESS_MODE_DISABLED
	if currently_hovered_field: currently_hovered_field.unhighlight()

func _process(delta):
	var field_areas = card.drop_point_detector.get_overlapping_areas()

	var hovered_field = card.home_field
	if !field_areas.is_empty():
		hovered_field = field_areas[0].get_parent()
		
	if currently_hovered_field != hovered_field and currently_hovered_field:
		currently_hovered_field.unhighlight()
	
	if hovered_field: hovered_field.highlight()
	currently_hovered_field = hovered_field


func on_input(event: InputEvent):
	var mouse_motion := event is InputEventMouseMotion
	var confirm = event.is_action_released("mouse_left")
	
	if mouse_motion:
		card.global_position = card.get_global_mouse_position() - card.pivot_offset
	
	if confirm:
		get_viewport().set_input_as_handled()
		transitioned.emit("Release")
