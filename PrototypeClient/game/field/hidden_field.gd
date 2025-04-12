extends Field

var owner_id

func update_cards_hiddeness():
	for card in cards_holder.get_children():
		if owner_id != multiplayer.get_unique_id():
			card.shroud()
		else: card.reveal()

func card_enter(card: Card):
	print(card, " entered ", self)
	if owner_id != multiplayer.get_unique_id():
		card.shroud()
	pass
	
func card_exit(card: Card):
	print(card, " exited ", self)
	card.reveal()
	pass
