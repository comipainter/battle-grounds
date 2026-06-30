# 使用随从
extends MinionAnimation
class_name MinionUseMagicPlayerAnimation

var usedMagic: Magic = null
var minion: Minion = null
func _init(_usedMagic: Magic, _minion: Minion) -> void:
	usedMagic = _usedMagic
	minion = _minion
func play() -> void:
		pass
		
class ReQingShaChuiShou extends MinionUseMagicPlayerAnimation:
	func play() -> void:
		if usedMagic.get_info().is_suzao():
			if minion.get_info().get_counter_info().get_count() < 1:
				minion.get_info().get_counter_info().add_count(1)
				var new_info: MagicInfo = usedMagic.get_info().copy()
				new_info.set_uniqueId(DataManager.get_uniqueId())
				CardUtils.create_hand_card(
					new_info,
					minion.global_position,
					minion
				)
		
class XiLiWaZi extends MinionUseMagicPlayerAnimation:
	func play() -> void:
		if minion.get_info().get_counter_info().get_count() <  minion.get_info().get_counter_info().get_limit():
			minion.get_info().get_counter_info().add_count(1)
			# 创建释放的法术的塑造版
			var new_info: MagicInfo = usedMagic.get_info().copy()
			new_info.set_uniqueId(DataManager.get_uniqueId())
			new_info.set_suzao(true)
			CardUtils.create_hand_card(
				new_info,
				minion.global_position,
				minion
			)

class FengBaoFenLiuZhe extends MinionUseMagicPlayerAnimation:
	func play() -> void:
		minion.get_info().get_click_info().create(
			true,
			"",
			Vector2(1, 1),
			Vector2(0, 0),
			MinionClickSpriteAnimation.new(),
			MinionClickFunction.new(func():return "hit"),
			MinionHitFunction.new(func(_minion: Minion):
				_minion.get_info().get_click_info().set_able(false)
				_minion.get_info().get_counter_info().add_count(1)
				)
		)
