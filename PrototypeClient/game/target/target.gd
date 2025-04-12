extends Line2D

signal object_targeted

var current_control = null

func _ready():
	print(get_tree().root.get_children(true).size())
	for child in get_all_children(get_tree().root):
		if child is Control:
			child.mouse_entered.connect(_on_mouse_entered_control.bind(child))
			
func _on_mouse_entered_control(control):
	current_control = control
	
func get_all_children(node: Node):
	var out = [node]
	for child in node.get_children():
		if child.get_child_count() > 0:
			out.append_array(get_all_children(child))
	return out

func _process(delta):
	points[1] = get_global_mouse_position() - global_position
	
	if Input.is_action_just_pressed("mouse_left"):
		object_targeted.emit(self, current_control)
