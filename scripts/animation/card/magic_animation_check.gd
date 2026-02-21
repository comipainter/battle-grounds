class_name MagicAnimationCheck

static func check_use(magicList: Array[Card]) -> void:
	for magic in magicList:
		use(magic)

static func use(magic: Magic) -> void:
	match magic.get_cardName():
		"酒馆币":
			magic.add_animation(MagicAnimation.JiuGuanBi.new(magic))
		"掠夺者合约":
			magic.add_animation(MagicAnimation.LueDuoZheHeYue.new(magic))
