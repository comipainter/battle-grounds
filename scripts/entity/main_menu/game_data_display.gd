extends Control
class_name GameDataDisplay

@onready var container: ContainerComponent = $Panel/CardContainer
@onready var _curr_data: GameData = null
@onready var cardFather: Control = $CardFather

func _ready() -> void:
	container.set_sort_able(false)

func use_data(gameData: GameData) -> void:
	if _curr_data == gameData:
		return
	else:
		_curr_data = gameData
	_clear_all_children()
	load_collection(gameData.get_last_shop().get_desk_info_collection())
	
func load_collection(_collection: CardInfoCollection) -> void:
	container.set_sort_able(false)
	for cardInfo in _collection.get_array():
		var card: Card = CardUtils.create_card(cardInfo)
		cardFather.add_child(card)
		container.add_card(card)
		card.get_info().set_shop()
		card.get_move_component().disable_drag()
		card.position = Vector2(0, 0)
		card.use_info()
	
func _clear_all_children():
	while container.get_child_count() > 0:
		container.get_child(0).free()
