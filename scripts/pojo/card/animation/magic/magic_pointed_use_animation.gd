extends MagicAnimation
class_name MagicPointedUseAnimation

var magic: Magic
var pointed_minion: Minion
func _init(_magic: Magic, _pointed_minion: Minion) -> void:
	magic =  _magic
	pointed_minion = _pointed_minion
	
func play() -> void:
	magic.used.emit(magic)
	magic.add_animation(MagicAnimation.DeleteAnimation.new(magic))
	
class ShenChenLanDiao extends MagicPointedUseAnimation:
	func play() -> void:
		MinionUtils.add_stats_from_magic(
			magic,
			pointed_minion,
			StatsUtils.mul_stats(
				Stats.new(3, 3),
				(CardUtils.get_belong_player_effect(magic).find_effect(
					Effect_UseShenchenlandiao
				) as Effect_UseShenchenlandiao).get_value()+1
			)
		)
		super.play()

class ZaShuaQiShu extends MagicPointedUseAnimation:
	func play() -> void:
		pointed_minion.get_info().get_effect_collection().add_minion_effect(
			MinionEffect_QiShuZaShuai.new(
				StatsUtils.mul_stats(
					Stats.new(1, 1),
					(DataManager.get_player_info().get_player_effect_collection().find_effect(
						Effect_UseMagic
					) as Effect_UseMagic).get_value()+1
				),
				pointed_minion.get_info()
			)
		)
		super.play()
