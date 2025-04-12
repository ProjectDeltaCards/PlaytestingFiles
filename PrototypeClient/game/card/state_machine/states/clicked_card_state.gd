extends CardState

var timer = INF

func _enter():
	card.color_rect.color = Color.ORANGE
	card.label.text = "CLICKED"
	timer = .2
	
func _process(delta: float):
	timer -= delta

func on_input(event):
	if !Input.is_action_pressed("mouse_left"):
		if timer > 0:
			transitioned.emit("Click/Release")
			return
		transitioned.emit("Hover")
		
	if event is InputEventMouseMotion:
		transitioned.emit("Drag")
		
