class_name Slot
extends Field

func set_new_card(card: Card):
	if cards_holder.get_child_count() > 0:
		card.home_field.return_card_starting_position(card)
		return
		
	card_reposition(card)
	card.home_field = self
