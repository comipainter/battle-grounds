extends MagicComponent
class_name MagicShopInfoComponent

@onready var backgroundComponent: MagicBackgroundComponent = $Background
@onready var levelComponent: CardLevelComponent = $Level
@onready var costComponent: MagicCostComponent = $Cost

func set_magic(_magic: Magic):
	super.set_magic(_magic)
	backgroundComponent.set_magic(_magic)
	levelComponent.set_level(magic.get_info().get_level())
	costComponent.set_magic(_magic)
	
func use_info() -> void:
	backgroundComponent.use_info()
	levelComponent.use_info()
	costComponent.use_info()

var able: bool = true
func set_able(_able) -> void:
	if able != _able:
		backgroundComponent.set_able(_able)
		costComponent.set_able(_able)
		levelComponent.set_able(_able)
		able = _able
		
