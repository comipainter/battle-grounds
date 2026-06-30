extends Control
class_name EffectPanel

@onready var descriptionLabel: Label = $EffectPanel/EffectDescriptionLabel
@onready var sprite: Sprite2D = $EffectPanel/EffectSprite

func display(_effect: PlayerEffect) -> void:
	descriptionLabel.text = _effect.get_description()
	sprite.texture = load(_effect.get_sprite_path())

func display_base_minion(_minion: Minion) -> void:
	if _minion.get_info().is_golden():
		descriptionLabel.text = _minion.get_info().get_goldenDescription()
	else:
		descriptionLabel.text = _minion.get_info().get_description()
	sprite.texture = load(_minion.get_info().get_spritePath())
	
func display_minion_effect(_effect: MinionEffect) -> void:
	descriptionLabel.text = _effect.get_description()
	sprite.texture = load(_effect.get_sprite_path())
