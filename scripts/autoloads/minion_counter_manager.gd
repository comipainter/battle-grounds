extends Node
var _map: Dictionary = {}

func match(
	counter_name: String
) -> Callable:
	if not _map.has(counter_name):
		return func():pass
	return _map[counter_name]

func _register(
	counter_name: String,
	init_func: Callable
) -> void:
	if not _map.has(counter_name):
		_map[counter_name] = {}
	_map[counter_name] = init_func
	
func _ready() -> void:
	_registry()
	
func _registry() -> void:
	_register(
		"齐恩瓦拉",
		MinionCounterFunction.QiEnWaLa.run
	)
	_register(
		"永燃火凤",
		MinionCounterFunction.YongRanHuoFeng.run
	)
	_register(
		"尸体提炼师",
		MinionCounterFunction.ShiTiTiLianShi.run
	)
	_register(
		"金币诈骗犯",
		MinionCounterFunction.JinBiZhaPianFan.run
	)
	_register(
		"咒缚海员",
		MinionCounterFunction.ZhouFuHaiYuan.run
	)
	_register(
		"海浪剃刀号",
		MinionCounterFunction.HaiLangTiDaoHao.run
	)
	_register(
		"空军上将罗杰斯",
		MinionCounterFunction.KongJunShangJiangLuoJieSi.run
	)
	_register(
		"热情沙锤手",
		MinionCounterFunction.ReQingShaChuiShou.run
	)
	_register(
		"希里瓦兹",
		MinionCounterFunction.XiLiWaZi.run
	)
	_register(
		"伊辛迪奥斯",
		MinionCounterFunction.YiXinDiAoSi.run
	)
	_register(
		"风暴分流者",
		MinionCounterFunction.FengBaoFenLiuZhe.run
	)
