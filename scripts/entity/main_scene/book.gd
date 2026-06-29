extends Control
class_name Book

@onready var container: FlowContainer = $Panel/Card/ScrollContainer/FlowContainer
@onready var cardFather: Control = $CardFather


func display_card_collection(_collection: CardInfoCollection) -> void:
	_clear_all_children()
	for cardInfo in _collection.get_array():
		var card: Card = CardUtils.create_card(cardInfo)
		var target = Control.new()
		target.custom_minimum_size  = Vector2(0, 0)
		container.add_child(target)
		var target1 = Control.new()
		target.add_child(target1)
		target1.position = Vector2(60, 200)
		target1.add_child(card)
		card.position = Vector2(0, 0)
		card.get_info().set_shopping_shop()
		card.get_move_component().disable_drag()
		card.get_move_component().disable_follow()
		card.use_info()
		if card.get_info().is_minion():
			card.get_interaction_component().mouse_up.connect(
				_on_minion_card_button_up.bind(card)
			)
		elif card.get_info().is_magic():
			card.get_interaction_component().mouse_up.connect(
				_on_magic_card_button_up.bind(card)
			)
	for i in range(10):
		var target = Control.new()
		target.custom_minimum_size  = Vector2(0, 0)
		container.add_child(target)

func _on_minion_card_button_up(card: Card) -> void:
	if is_instance_valid(GameManager.mainScene):
		DataManager.get_shop_info().create_hand_card_info(
			# 通过名字生产原始版
			CardUtils.create_minion_info(DataManager.get_all_minion_data().filter_by(
				MinionDataCollection.Filter.new().set_name(
					card.get_info().get_card_name()
				)
			).get_array().get(0)),
			card.global_position
		)
		
func _on_magic_card_button_up(card: Card) -> void:
	if is_instance_valid(GameManager.mainScene):
		DataManager.get_shop_info().create_hand_card_info(
			# 通过名字生产原始版
			CardUtils.create_magic_info(DataManager.get_all_magic_data().filter_by(
				MagicDataCollection.Filter.new().set_name(
					card.get_info().get_card_name()
				)
			).get_array().get(0)),
			card.global_position
		)

func _clear_all_children():
	while container.get_child_count() > 0:
		container.get_child(0).free()
	while cardFather.get_child_count() > 0:
		cardFather.get_child(0).free()

func _on_zhongli_button_button_up() -> void:
	display_card_collection(
		CardInfoCollection.new().add_minion_collection(
			CardUtils.create_minion_info_collection(
				DataManager.allMinionDataCollection.filter_by(
					MinionDataCollection.Filter.new().set_race(Race.Type.ZhongLi)
				)
			)
		)
	)

func _on_hai_dao_button_button_up() -> void:
	display_card_collection(
		CardInfoCollection.new().add_minion_collection(
			CardUtils.create_minion_info_collection(
				DataManager.allMinionDataCollection.filter_by(
					MinionDataCollection.Filter.new().set_race(Race.Type.HaiDao)
				)
			)
		)
	)
	
func _on_yuan_su_button_button_up() -> void:
	display_card_collection(
		CardInfoCollection.new().add_minion_collection(
			CardUtils.create_minion_info_collection(
				DataManager.allMinionDataCollection.filter_by(
					MinionDataCollection.Filter.new().set_race(Race.Type.YuanSu)
				)
			)
		)
	)


func _on_na_jia_button_button_up() -> void:
	display_card_collection(
		CardInfoCollection.new().add_minion_collection(
			CardUtils.create_minion_info_collection(
				DataManager.allMinionDataCollection.filter_by(
					MinionDataCollection.Filter.new().set_race(Race.Type.NaJia)
				)
			)
		)
	)


func _on_magic_button_button_up() -> void:
	display_card_collection(
		CardInfoCollection.new().add_magic_collection(
			CardUtils.create_magic_info_collection(
				DataManager.allMagicDataCollection
			)
		)
	)

signal exited
func _on_end_button_button_up() -> void:
	exited.emit()
