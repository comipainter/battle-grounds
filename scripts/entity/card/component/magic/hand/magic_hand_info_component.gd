extends MagicComponent
class_name MagicHandInfoComponent

@onready var backgroundComponent: MagicBackgroundComponent = $Background
@onready var nameComponent: MagicHandNameComponent = $Name
@onready var descriptionComponent: MagicHandDescriptionComponent = $Description
@onready var levelComponent: CardLevelComponent = $Level

func set_magic(_magic: Magic):
	super.set_magic(_magic)
	backgroundComponent.set_magic(_magic)
	levelComponent.set_level(magic.get_info().get_level())
	descriptionComponent.set_magic(_magic)
	nameComponent.set_magic(_magic)
	
func use_info() -> void:
	backgroundComponent.use_info()
	levelComponent.use_info()
	descriptionComponent.use_info()
	nameComponent.use_info()

var able: bool = true
func set_able(_able) -> void:
	if able != _able:
		backgroundComponent.set_able(_able)
		levelComponent.set_able(_able)
		descriptionComponent.set_able(_able)
		nameComponent.set_able(_able)
		able = _able
		
