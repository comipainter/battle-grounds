extends Control
class_name FightHandleComponent

@onready var fightComponent: FightComponent = get_parent()

var cardComponent: FightCardComponent
func get_card_component() -> FightCardComponent:
	return cardComponent

func init() -> void:
	cardComponent = fightComponent.get_card_component()

var able: bool = false
func set_able(_able) -> void:
	able = _able

# 信号
signal finished(winner: String)

# 行动方
enum Side{Player, Player_Attacking, Enemy, Enemy_Attacking, None}
var side: FightHandleComponent.Side = Side.None

func start() -> void:
	# 随机初始化先手方
	randomize()
	side = randi_range(Side.Player, Side.Enemy) as FightHandleComponent.Side
	attacked_uniqueIds = []
	fengnu_attacker = null
	fengnu_round = false
	set_able(true)
	
	
func _process(delta: float) -> void:
	if able == false:
		return 
	if _is_all_idle() == false or side == Side.None:
		return
	else: # 全场空闲进入下一次攻击
		# 先判断有没有一方是阵亡的
		if _is_player_card_dead() and _is_enemy_card_dead():
			print("战斗结束，平局")
			side = Side.None	
			finished.emit("player")
		elif _is_player_card_dead():
			print("战斗结束，敌方胜利")
			side = Side.None
			finished.emit("enemy")
		elif _is_enemy_card_dead():
			print("战斗结束，玩家胜利")
			side = Side.None
			finished.emit("player")
		else:
			match side:
				Side.Player_Attacking:
					side = Side.Enemy
				Side.Enemy_Attacking:
					side = Side.Player
		if fengnu_round: # 说明当前回合是风怒随从发起额外攻击回合
			if is_instance_valid(fengnu_attacker): # 如果风怒随从还在，则触发，恢复side为另一方
				match side:
					Side.Player:
						side = Side.Enemy
						attack_by_side()
					Side.Enemy:
						side = Side.Player
						attack_by_side()
				return
		# 说明当前回合不是风怒额外回合或者风怒随从已经不存在了，则正常触发
		attack_by_side()
		
func attack_by_side() -> void:
	match side:
		Side.Player:
			# 玩家方发起攻击
			side = Side.Player_Attacking
			attack(
				get_attack_minion(get_card_component().get_player_desk_card_collection().get_minion_collection()),
				get_card_component().get_enemy_desk_card_collection().get_minion_collection().get_behit_minion()
			)
		Side.Enemy:
			# 敌方发起攻击
			side = Side.Enemy_Attacking
			attack(
				get_attack_minion(get_card_component().get_enemy_desk_card_collection().get_minion_collection()),
				get_card_component().get_player_desk_card_collection().get_minion_collection().get_behit_minion()
			)
			
func _is_all_idle() -> bool:
	return get_card_component().get_player_desk_card_collection().is_all_idle() and \
	get_card_component().get_player_hand_card_collection().is_all_idle() and \
	get_card_component().get_enemy_desk_card_collection().is_all_idle() and \
	get_card_component().get_enemy_hand_card_collection().is_all_idle()
	
func _is_player_card_dead() -> bool:
	return get_card_component().get_player_desk_card_collection().size() == 0

func _is_enemy_card_dead() -> bool:
	return get_card_component().get_enemy_desk_card_collection().size() == 0

# 发起攻击
func attack(attackMinion: Minion, behitMinion: Minion) -> void:
	if attackMinion != null and behitMinion != null:
		attackMinion.add_animation(MinionAnimation.AttackStartAnimation.new(attackMinion, behitMinion))

# 选择发起攻击的随从
# 使用uniqueId记录已经攻击过的随从
var attacked_uniqueIds: Array[String] = []
var fengnu_attacker: Minion = null
var fengnu_round: bool = false
func get_attack_minion(_collection: MinionCollection) -> Minion:
	if _collection.size() == 0:
		push_error("find attack minion in NULL collection")
		return null
	if is_instance_valid(fengnu_attacker):
		# 如果风怒随从本轮攻击次数小于2，则同意其发起攻击
		var unique_id = fengnu_attacker.get_info().get_uniqueId()
		if attacked_uniqueIds.count(unique_id) < 2:
			if attacked_uniqueIds.count(unique_id) == 1: # 说明这是风怒随从最后一次攻击
				fengnu_round = false # 则使下回合变为普通回合
			attacked_uniqueIds.append(unique_id)
			return fengnu_attacker
	# 如果没有风怒随从不存在或者已经攻击了大于等于两次了，则解除风怒特殊回合
	fengnu_attacker = null
	fengnu_round = false
	var minion_array: Array[Minion] = []
	# 先把存活的随从选出来
	for minion: Minion in _collection.sort_by_position().get_array():
		if minion.get_info().get_stats().get_health() > 0:
			minion_array.append(minion)
	if minion_array.size() == 0:
		push_error("no minion live")
		return null
	for minion: Minion in minion_array:
		if minion.get_info().get_uniqueId() not in attacked_uniqueIds:
			attacked_uniqueIds.append(minion.get_info().get_uniqueId())
			if minion.get_info().get_keyword_info().is_fengnu():
				fengnu_attacker = minion # 风怒随从在自己第一次攻击时将下次攻击的随从设定为自己
				fengnu_round = true # 标记下次回合为风怒随从的额外攻击回合
			return minion
	# 说明当前已经所有随从已经攻击过了，清空uniqueId记录并返回最左侧的随从
	attacked_uniqueIds.clear()
	var leftestMinion: Minion = minion_array[0]
	attacked_uniqueIds.append(leftestMinion.get_info().get_uniqueId())
	return leftestMinion
