extends Control
class_name BuyComponent

@onready var areaComponent: AreaComponent = $BuyArea
@onready var shopComponent: ShopComponent = get_parent()
@onready var info: ShopInfo = DataManager.get_shop_info()

func init() -> void:
	shopComponent.get_card_component().card_created.connect(
		func(card: Card):
			card.mouse_up.connect(
				func(card: Card):
					if _check_can_buy(card, get_global_mouse_position()):
						buy(card)
			)
	)

func _check_can_buy(card: Card, _position: Vector2) -> bool:
	if card.get_info().is_shopping_shop():
		if areaComponent.is_inside(_position):
			if info.get_coin() >= card.get_info().get_cost():
				return true
	return false

signal brought(card)
func buy(card: Card) -> void:
	if DataManager.get_shop_info().get_hand_info_collection().size() >= DataManager.get_player_info().get_hand_card_num():
		return
	info.sub_coin(card.get_info().get_cost())
	info.move_card_to_hand(card.get_info())
	brought.emit(card)

var able: bool = true
func set_able(_able):
	if able == _able:
		return
	if _able:
		self.visible = true
		areaComponent.able()
	else:
		self.visible = false
		areaComponent.disable()
	able = _able
