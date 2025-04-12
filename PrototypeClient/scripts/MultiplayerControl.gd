extends Control
class_name MultiplayerControl

signal parent_changed

func set_parent_synced(parent: Node, index = get_index()):
	if multiplayer.multiplayer_peer == null:
		reparent(parent)
		parent.move_child(self, index)
		parent_changed.emit(parent)
	else:
		_set_parent_impl(parent.get_path(), index)

func _set_parent_impl(new_path : NodePath, new_index, senderID = 1):
	if !(is_multiplayer_authority() or senderID == 0):
		_set_parent_rpc.rpc_id(get_multiplayer_authority(), new_path, new_index, multiplayer.get_unique_id())
		return
		
	var new_parent = get_tree().root.get_node(new_path)
	
	# Make sure the value change gets propigated to all of the clients! 
	if is_multiplayer_authority() and senderID != 0:
		print(senderID, " has set the parent to: ", new_parent, " and index to: ", new_index)
		_set_parent_rpc.rpc(new_path, new_index, 0)
		
	reparent(new_parent)
	new_parent.move_child(self, new_index)
	parent_changed.emit(new_parent)

@rpc("any_peer")
func _set_parent_rpc(new_path : NodePath, index, senderID):
	if is_multiplayer_authority() or senderID == 0:
		_set_parent_impl(new_path, index, senderID)
		
func set_position_synced(new_position: Vector2):
	if multiplayer.multiplayer_peer == null:
		position = new_position
	else: _set_position_impl(new_position)

func _set_position_impl(new_position: Vector2, senderID = 1):
	if !(is_multiplayer_authority() or senderID == 0):
		_set_position_rpc.rpc_id(get_multiplayer_authority(), new_position, multiplayer.get_unique_id())
		return
		
	position = new_position
	
	# Make sure the value change gets propigated to all of the clients! 
	if is_multiplayer_authority() and senderID != 0:
		print(senderID, " has set the position to: ", new_position)
		_set_position_rpc.rpc(new_position, 0)

@rpc("any_peer")
func _set_position_rpc(position: Vector2, senderID):
	if is_multiplayer_authority() or senderID == 0:
		_set_position_impl(position, senderID)
		
func _ready():
	set_parent_synced(get_parent())
	set_position_synced(position)
	
