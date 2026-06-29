extends Control
class_name TripleHandleComponent

@onready var shopComponent: ShopComponent = get_parent()

var cardComponent: ShopCardComponent = null
func init() -> void:
	cardComponent = shopComponent.get_card_component()
	shopComponent.round_ended.connect(
		set_able.bind(false)
	)

var able: bool = false
func set_able(_able):
	if able == _able:
		return
	if _able:
		self.visible = true
	else:
		self.visible = false
	able = _able
	
var triple_task: MinionCollection = MinionCollection.new()

func check_triple() -> void:
	if triple_task == null:
		return
	if cardComponent == null:
		return 
	if triple_task.size() != 0:
		# 如果有三连则尝试合并
		# 先设置三连锁免得误合并
		for minion in triple_task.get_array():
			minion.set_triple_lock(true)
		# 确保三个随从都处于动画空闲状态
		for minion in triple_task.get_array():
			if is_instance_valid(minion) == false: # 如果有随从已经不存在了
				for _minion in triple_task.get_array(): # 则解除剩余随从的三连锁
					if is_instance_valid(minion) == true: 
						_minion.set_triple_lock(false)
				triple_task = MinionCollection.new()
				return
			if minion.get_animation_component().get_card_animation_collection().is_idle()==false:
				return
		var new_minion_info: MinionInfo = MinionUtils.triple(
			triple_task.get_array().get(0).get_info(),
			triple_task.get_array().get(1).get_info(),
			triple_task.get_array().get(2).get_info()
		)
		# 添加三连移除动画,同时计算三连后的属性值
		for minion in triple_task.get_array():
			minion.add_animation(MinionAnimation.BeTripleAnimation.new(minion))
			
		# 适当延时
		await get_tree().create_timer(0.5).timeout
		# 新建金色随从
		#var new_minion_info: MinionInfo = CardUtils.create_minion_info(
			#DataManager.get_all_minion_data().filter_by(
				#MinionDataCollection.Filter.new().set_id(minion_id)
			#).get_array().get(0)
		#)
		
		DataManager.get_shop_info().create_hand_card_info(new_minion_info, Vector2.ZERO)
		triple_task = MinionCollection.new()
		return
	
	# 检测逻辑
	var collection: MinionCollection = cardComponent.get_desk_card_collection().add_collection(
		cardComponent.get_hand_card_collection()
	).get_minion_collection().remove_ronghe().sort_by_id()
	# 检查有没有三个一样的
	for i in range(collection.size()):
		if i == 0 or i == 1:
			continue
		else:
			if collection.get_array().get(i).get_info().is_golden() == true:
				continue
			if collection.get_array().get(i-1).get_info().is_golden() == true:
				continue
			if collection.get_array().get(i-2).get_info().is_golden() == true:
				continue
			if collection.get_array().get(i).get_triple_lock() == true:
				continue
			if collection.get_array().get(i-1).get_triple_lock() == true:
				continue
			if collection.get_array().get(i-2).get_triple_lock() == true:
				continue
			var id_1 = collection.get_array().get(i).get_info().get_id()
			var id_2 = collection.get_array().get(i-1).get_info().get_id()
			var id_3 = collection.get_array().get(i-2).get_info().get_id()
			if id_1 == id_2 and id_1 == id_3:
				# 找到三连目标
				triple_task.add(
					collection.get_array().get(i)
				).add(
					collection.get_array().get(i-1)
				).add(
					collection.get_array().get(i-2)
				)
				# 先设置三连锁免得误合并
				collection.get_array().get(i).set_triple_lock(true)
				collection.get_array().get(i-1).set_triple_lock(true)
				collection.get_array().get(i-2).set_triple_lock(true)
				break

func _process(delta: float) -> void:
	if able:
		check_triple()
