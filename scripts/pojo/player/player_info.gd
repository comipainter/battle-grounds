extends Resource
class_name PlayerInfo

func copy() -> PlayerInfo:
	return duplicate(true)

# 逻辑方法
signal dead
func take_damage(_damage: int):
	if get_shield() > 0:
		if get_shield() > _damage:
			set_shield(get_shield()-_damage)
		else:
			_damage -= get_shield()
			set_shield(0)
			set_blood(get_blood()-_damage)
	else:
		set_blood(get_blood()-_damage)
	if get_blood() <= 0:
		dead.emit()

# 运行信息
@export var blood: int = PlayerConstant.get_init_blood()
@export var shield: int = PlayerConstant.get_init_shield()
@export var hand_card_num: int = PlayerConstant.get_init_hand_card_num()
@export var desk_card_num: int = PlayerConstant.get_init_desk_card_num()

signal blood_changed
func set_blood(_blood: int) -> void:
	blood = _blood
	blood_changed.emit()
func get_blood() -> int:
	return blood

signal shield_changed
func set_shield(_shield: int) -> void:
	shield = _shield
	shield_changed.emit()
func get_shield() -> int:
	return shield
	
func set_hand_card_num(_num: int) -> void:
	hand_card_num = _num
func get_hand_card_num() -> int:
	return hand_card_num
	
func set_desk_card_num(_num: int) -> void:
	desk_card_num = _num
func get_desk_card_num() -> int:
	return desk_card_num
	
	
@export var currWinNum: int = 0
signal win_num_changed
func set_curr_win_num(_num: int) -> void:
	currWinNum = _num
	win_num_changed.emit()
func get_curr_win_num() -> int:
	return currWinNum

@export var score: int = 0 # 预收入的score
signal score_changed
func set_score(_score: int) -> void:
	score = _score
	score_changed.emit()
func get_score() -> int:
	return score
	
@export var handCardInfoCollection: CardInfoCollection = CardInfoCollection.new()
func set_hand_info_collection(_collection: CardInfoCollection) -> void:
	handCardInfoCollection = _collection
func get_hand_info_collection() -> CardInfoCollection:
	return handCardInfoCollection

@export var deskCardInfoCollection: CardInfoCollection = CardInfoCollection.new()
func set_desk_info_collection(_collection: CardInfoCollection) -> void:
	deskCardInfoCollection = _collection
func get_desk_info_collection() -> CardInfoCollection:
	return deskCardInfoCollection

@export var playerEffectCollection: PlayerEffectCollection = PlayerEffectCollection.new()
func get_player_effect_collection() -> PlayerEffectCollection:
	return playerEffectCollection
func set_player_effect_collection(_collection: PlayerEffectCollection) -> void:
	playerEffectCollection = _collection
