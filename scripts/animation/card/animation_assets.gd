class_name AnimationAssets

var chooseTemplate = preload("res://scenes/animation/choose_card.tscn")
var HuoYaoYunShuGong_Particles_Template = preload("res://scenes/animation/HuoYaoYunShuGong_Particles.tscn")
var DeLuSiTe_Particles_Template = preload("res://scenes/animation/DeLuSiTe_Particles.tscn")

var LianTui_AddInfo_Texture = preload("res://assets/image/animation/LianTui_AddInfo.png")
var GeLeiSiFaXiEr_OptionList = [
	{"discription": "下回合铸币数量+3", "sprite": preload("res://assets/image/minion/格蕾丝法希尔.png"), "sprite_scale": Vector2(0.4, 0.4)},
	{"discription": "两回合后铸币数量+5", "sprite": preload("res://assets/image/minion/格蕾丝法希尔.png"), "sprite_scale": Vector2(0.4, 0.4)}
	]
var GouWei_AddInfo_Texture = preload("res://assets/image/animation/LianTui_AddInfo.png")
var HuoYaoYunShuGong_Texture = preload("res://assets/image/animation/HuoYaoYunShuGong_AddInfo.png")
var zhanhouButtonTemplate = preload("res://scenes/animation/zhanhou_button.tscn")

var LuoShuLongGuFan_Template = preload("res://scenes/animation/LuoShuLongGuFan_Particles.tscn")
var LuoShuLongGuFan_HitPositionList: Array[Vector2] = [
	Vector2(0, -50),
	Vector2(50, 0),
	Vector2(0, 50),
	Vector2(-50, 0),
	Vector2(30, -30),
	Vector2(-30, -30),
	Vector2(30, 30),
	Vector2(-30, 30)
]
var LuoShuLongGuFan_HitRadius: int = 60

var HuangJinKuangChao_Sprite = "res://assets/image/minion/click.png"
var HuangJinKuangChao_Sprite_Scale = Vector2(0.438, 0.438)
var HuangJinKuangChao_Particles_Template = preload("res://scenes/animation/HuangJinKuangChao_Particles.tscn")

class YuanSuAddInfo:
	static var baoliejufeng: Stats = Stats.new(1, 0)
	static var paiduiyuansu: Stats = Stats.new(2, 3)
	static var kuangfangdefali: Stats = Stats.new(1, 1)
	static func get_stats(stats: Stats) -> Stats:
		return Stats.add_stats(stats, PlayerEffectCheck.find_effect(PlayerEffect.YuanSuStatsBuff.new(Stats.new(0, 0))).get_stats())
