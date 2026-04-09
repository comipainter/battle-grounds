extends Control

class_name EffectPanel

@export var effectDescriptionLabel: Label
@export var effectSprite: Sprite2D

enum TYPE{MINIONEFFECT, PLAYEREFFECT, MINIONINFO}
var type: TYPE = TYPE.MINIONEFFECT

var minionEffect: MinionEffect
var playerEffect: PlayerEffect
var baseMinionInfo: MinionInfo

func set_minionEffect(effect: MinionEffect) -> void:
	minionEffect = effect
	type = TYPE.MINIONEFFECT
	
func set_playerEffect(effect: PlayerEffect) -> void:
	playerEffect = effect
	type = TYPE.PLAYEREFFECT
	
func set_baseMinionInfo(minionInfo: MinionInfo) -> void:
	baseMinionInfo = minionInfo
	type = TYPE.MINIONINFO

func _ready() -> void:
	match type:
		TYPE.MINIONEFFECT:
			effectDescriptionLabel.text = minionEffect.description
			effectSprite.texture = load(minionEffect.spritePath)
		TYPE.PLAYEREFFECT:
			effectDescriptionLabel.text = playerEffect.description()
			effectSprite.texture = load(playerEffect.spritePath)
		TYPE.MINIONINFO:
			effectDescriptionLabel.text = baseMinionInfo.description
			effectSprite.texture = load(baseMinionInfo.spritePath)
