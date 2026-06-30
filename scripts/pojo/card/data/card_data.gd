extends Resource
class_name CardData

@export var id: int
@export var name: String
@export var level: int
@export var description: String
@export var spritePath: String
@export var sellable: bool

func copy() -> CardData:
	return duplicate(true)

func get_id() -> int:
	return id

func get_card_name() -> String:
	return name

func get_level() -> int:
	return level

func get_description() -> String:
	return description

func get_sprite_path() -> String:
	return spritePath

func is_sellable() -> bool:
	return sellable
	
