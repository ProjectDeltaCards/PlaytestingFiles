extends Control
@onready var address_label = $JoinContainer/Address

const GAME = preload("res://game/game.tscn")
const PORT = 2084
var peer = ENetMultiplayerPeer.new()

func button_common():
	var game = GAME.instantiate()
	get_parent().add_child(game)
	hide.call_deferred()

func _on_host_button_pressed():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	button_common()
	
func _on_join_button_pressed():
	peer.create_client(address_label.text, PORT)
	multiplayer.multiplayer_peer = peer
	button_common()
