extends Resource
class_name CardInfo

@export var id: int
@export var uniqueId: String
@export var name: String
@export var level: int
@export var description: String
@export var spritePath: String
@export var type: CardType = CardType.new()
@export var belong: CardBelong = CardBelong.new()
@export var sellable: bool

func copy() -> CardInfo:
	return duplicate(true)

func get_id() -> int:
	return id

func set_uniqueId(_uniqueId: String) -> void:
	self.uniqueId = _uniqueId
func get_uniqueId() -> String:
	return uniqueId

func get_card_name() -> String:
	return name

func get_level() -> int:
	return level

func get_description() -> String:
	return description

func get_spritePath() -> String:
	return spritePath

func is_sellable() -> bool:
	return sellable

func is_minion() -> bool:
	return type.is_minion()
func is_magic() -> bool:
	return type.is_magic()

func is_shopping_shop() -> bool:
	return belong.is_shopping_shop()
func is_shopping_desk() -> bool:
	return belong.is_shopping_desk()
func is_shopping_hand() -> bool:
	return belong.is_shopping_hand()
func is_shopping_free() -> bool:
	return  belong.is_shopping_free()
func is_enemy_desk() -> bool:
	return belong.is_enemy_desk()
func is_enemy_hand() -> bool:
	return belong.is_enemy_hand()
func is_player_desk() -> bool:
	return belong.is_player_desk()
func is_player_hand() -> bool:
	return belong.is_player_hand()
func is_player_free() -> bool:
	return belong.is_player_free()
func is_enemy_free() -> bool:
	return belong.is_enemy_free()
func is_none() -> bool:
	return belong.is_none()

func is_player() -> bool:
	return belong.is_player()
func is_enemy() -> bool:
	return belong.is_enemy()
func is_shopping() -> bool:
	return belong.is_shopping()
func is_hand() -> bool:
	return belong.is_player_hand() or belong.is_enemy_hand() or belong.is_shopping_hand()
func is_desk() -> bool:
	return belong.is_player_desk() or belong.is_enemy_desk() or belong.is_shopping_desk()

func set_shopping_shop() -> void:
	belong.set_shopping_shop()
func set_shopping_desk() -> void:
	belong.set_shopping_desk()
func set_shopping_hand() -> void:
	belong.set_shopping_hand()
func set_shopping_free() -> void:
	belong.set_shopping_free()
func set_enemy_desk() -> void:
	belong.set_enemy_desk()
func set_enemy_hand() -> void:
	belong.set_enemy_hand()
func set_player_desk() -> void:
	belong.set_player_desk()
func set_player_hand() -> void:
	belong.set_player_hand()
func set_player_free() -> void:
	belong.set_player_free()
func set_enemy_free() -> void:
	belong.set_enemy_free()
func set_none() -> void:
	belong.set_none()

# 衍生方法
func get_cost() -> int:
	if self.is_minion():
		return DataManager.get_shop_info().get_buy_minion_cost()
	else:
		return (self as MagicInfo).get_cost()
