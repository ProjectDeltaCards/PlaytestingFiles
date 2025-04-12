extends HBoxContainer

func _ready() -> void:
	var parent = get_parent()
	var index = parent.get_children().find(self)

	var vbox = VBoxContainer.new()
	vbox.name = name
	name = "Deleting"
	print("new: ", vbox)
	parent.add_child.call_deferred(vbox)
	parent.move_child.call_deferred(vbox, index)
	parent.set.call_deferred("cards_holder", vbox)
	var tween = get_tree().create_tween()
	tween.tween_callback((func(parent): parent.ready_cards()).bind(parent)).set_delay(.3)
	
	self.queue_free()
