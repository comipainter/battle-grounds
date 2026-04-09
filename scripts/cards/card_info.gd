class_name CardInfo
func _init(cardData: Dictionary) -> void:
	id = cardData["id"]
	name = cardData["name"]
	level = cardData["level"]
	description = cardData["description"]
	spritePath = cardData["sprite_path"]
	type = cardData["type"]
	if cardData["sellable"] == "1":
		sellable = true
	else:
		sellable = false
	
var id: int

var name: String

var level: int

var description: String

var spritePath: String

var type: String

var sellable: bool

func create() -> CardInfo:
	return duplicate()

func duplicate() -> CardInfo:
	var copy = CardInfo.new(_to_dict())
	return copy

func _to_dict() -> Dictionary:
	return {
		"id": id,
		"name" : name,
		"level" : level,
		"description" : description,
		"sprite_path" : spritePath,
		"type" : type,
		"sellable": str(int(sellable))
	}
