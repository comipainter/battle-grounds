extends Control
class_name Usecomponent

@onready var areaComponent: AreaComponent = $UseArea
@onready var shopComponent: ShopComponent = get_parent()
@onready var info: ShopInfo = DataManager.get_shop_info()

func init() -> void:
	shopComponent.get_card_component().card_created.connect(
		func(card: Card):
			card.mouse_up.connect(
				func(card: Card):
					if _check_can_use(card, get_global_mouse_position()):
						use(card)
			)
	)

func _check_can_use(card: Card, _position: Vector2) -> bool:
	if card.get_info().is_shopping_hand():
		if areaComponent.is_inside(_position):
			return true
	return false

signal used(card)
func use(card: Card) -> void:
	if card.is_in_group("minion"):
		if DataManager.get_shop_info().get_desk_info_collection().size() >= DataManager.get_player_info().get_desk_card_num():
			return
		# 如果随从是磁力随从，提前获得其即将吸附的随从
		var xifuMinion: Minion = null
		if (card as Minion).get_info().is_cili():
			xifuMinion = MinionUtils.get_xifu(
				(card as Minion), 
				shopComponent.get_card_component().get_desk_card_collection().get_minion_collection().erase((card as Minion))
			)
		info.move_card_to_desk(card.get_info())
		used.emit(card)
		if (card as Minion).get_info().is_cili():
			if is_instance_valid(xifuMinion):
				(card as Minion).add_animation(
					MinionAnimation.XifuAnimation.new((card as Minion), xifuMinion)
				)
	elif card.is_in_group("magic"):
		info.remove_card_info(card.get_info())
		used.emit(card)
	else:
		push_error("unknown card type")

func pointed_use(card: Card) -> void:
	if card.is_in_group("minion"):
		pass
	elif card.is_in_group("magic"):
		info.remove_card_info(card.get_info())
		used.emit(card)
	else:
		push_error("unknown card type")

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
