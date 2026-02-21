extends CardInfo
class_name MagicInfo

func _init(cardData: Dictionary) -> void:
	super._init(cardData)
	cost = cardData["cost"]

var cost: int

func duplicate() -> MagicInfo:
	var copy = MagicInfo.new(_to_dict())
	return copy

func _to_dict() -> Dictionary:
	var dict: Dictionary = super._to_dict()
	dict["cost"] = cost
	return dict
