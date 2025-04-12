extends CardState

var timer = INF
const ARROW = preload("res://game/target/target.tscn")

func _enter():
	card.color_rect.color = Color.RED
	card.label.text = "DOUBLE CLICK WINDOW"
	timer = .2
	
func _exit():
	timer = INF
	
func _process(delta: float):
	timer -= delta
	if timer < 0: transitioned.emit("Hover")

func on_gui_input(event):
	if event.is_action_pressed("mouse_left") and timer > 0:
		print("Double Clicked")
		var arrow = ARROW.instantiate()
		card.add_child(arrow)
		arrow.position = Vector2.ZERO
		arrow.points[0] = card.size / 2
		arrow.object_targeted.connect(func(arrow, card):
			if card is not Card: return
			
			card.attach_card(arrow.get_parent())
			arrow.queue_free()
		)
		transitioned.emit("Hover")
		
	#if event is InputEventMouseMotion:
		#transitioned.emit("Drag")
		
