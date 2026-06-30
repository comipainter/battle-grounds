extends Control
class_name ShopComponent

@onready var mainScene: MainScene = get_parent()
	
var info: ShopInfo = DataManager.get_shop_info()
func set_info(_info) -> void:
	info = _info
func get_info() -> ShopInfo:
	return info

# 卡牌相关
@onready var cardComponent: ShopCardComponent = $Card
func get_card_component() -> ShopCardComponent:
	return cardComponent

# 刷新相关
@onready var freshComponent: ShopFreshComponent = $Fresh
func get_fresh_component() -> ShopFreshComponent:
	return freshComponent
	
# 升级相关
@onready var upgradeComponent: ShopUpgradeComponent = $Upgrade
func get_upgrade_component() -> ShopUpgradeComponent:
	return upgradeComponent

# 购买相关
@onready var buyComponent: BuyComponent = $Buy
func get_buy_component() -> BuyComponent:
	return buyComponent

# 使用相关
@onready var useComponent: Usecomponent = $Use
func get_use_component() -> Usecomponent:
	return useComponent

# 出售相关
@onready var sellComponent: SellComponent = $Sell
func get_sell_component() -> SellComponent:
	return sellComponent

# 金币展示相关
@onready var coinComponent: CoinComponent = $Coin
func get_coin_component() -> CoinComponent:
	return coinComponent
	
# 倒计时相关
@onready var exitComponent: ExitComponent = $Exit
func get_exit_component() -> ExitComponent:
	return exitComponent
	
# 等级相关
@onready var levelComponent: LevelComponent = $Level
func get_level_component() -> LevelComponent:
	return levelComponent
	
# 读书相关
@onready var bookComponent: BookComponent = $Book
func get_book_component() -> BookComponent:
	return bookComponent
	
# 三连相关
@onready var tripleHandleComponent: TripleHandleComponent = $TripleHandle
func get_triple_handle_component() -> TripleHandleComponent:
	return tripleHandleComponent
	
# 信号
signal finished
signal round_ended
signal used(card: Card)
signal brought(card: Card)
	
# 初始化方法，由父节点的_ready方法或者init方法调用
func init() -> void:
	# 先完成自身的初始化逻辑
	useComponent.used.connect(used.emit)
	buyComponent.brought.connect(brought.emit)
	exitComponent.time_out.connect(round_end)
	exitComponent.button_up.connect(round_end)
	# 启动子节点初始化
	cardComponent.init()
	freshComponent.init()
	buyComponent.init()
	useComponent.init()
	upgradeComponent.init()
	coinComponent.init()
	sellComponent.init()
	exitComponent.init()
	levelComponent.init()
	tripleHandleComponent.init()
	
	set_able(false)
	
# 控制使能方法
func set_able(_able):
	cardComponent.set_able(_able)
	freshComponent.set_able(_able)
	buyComponent.set_able(_able)
	useComponent.set_able(_able)
	upgradeComponent.set_able(_able)
	coinComponent.set_able(_able)
	sellComponent.set_able(_able)
	exitComponent.set_able(_able)
	levelComponent.set_able(_able)
	tripleHandleComponent.set_able(_able)
	
# 商店页面退出前的方法,回合结束相关逻辑
func round_end() -> void:
	# 执行回合结束动画
	round_ended.emit()
	# 移除手中的塑造法术
	for cardInfo in info.get_hand_info_collection().get_array().duplicate():
		if cardInfo.is_magic():
			if (cardInfo as MagicInfo).is_suzao():
				info.delete_card_info(cardInfo)
	# 等待动画完结
	while _is_all_idle() == false:
		await get_tree().process_frame
	# 执行子节点回合结束逻辑
	upgradeComponent.round_end()
	finished.emit()
	
# 关闭商店页面的方法
signal closed
func close() -> Signal:
	# 先排序保证顺序无误
	var _desk_cards := cardComponent.get_desk_card_collection().get_array()
	_desk_cards.sort_custom(func(a: Card, b: Card) -> bool:
		return a.global_position.x < b.global_position.x
	)
	var _sorted_infos: Array[CardInfo] = []
	for _card in _desk_cards:
		_sorted_infos.append(_card.get_info())
	info.get_desk_info_collection().cardInfoArray = _sorted_infos
	# 保存数据
	DataManager.save_shop_info()
	
	# 关闭控件， 先启动关闭程序，然后等待
	await Utils.run_and_wait_all(
		[
			freshComponent.close,
			upgradeComponent.close,
			coinComponent.close,
			sellComponent.close,
			exitComponent.close,
			levelComponent.close,
			cardComponent.close
		]
	)
	
	return closed
	
# 开启商店页面的方法
signal round_started
func start() -> void:
	DataManager.get_game_info().set_curr_round_num(
		DataManager.get_game_info().get_curr_round_num() + 1
	)
	# 获取上一次的商店信息
	Utils.copy_properties(
		DataManager.get_last_shop().copy(),
		info
	)
	
	# 清空商店信息中的牌
	info.set_desk_info_collection(CardInfoCollection.new())
	info.set_hand_info_collection(CardInfoCollection.new())
	
	# 初始化玩家的牌
	info.set_desk_info_collection(DataManager.get_player_info().get_desk_info_collection())
	info.set_hand_info_collection(DataManager.get_player_info().get_hand_info_collection())
	
	# 将战斗中获取的手牌转化为商店阶段的
	for cardInfo in info.get_hand_info_collection().get_array():
		cardInfo.set_shopping_hand()
	
	# 控件开始方法
	set_able(true)
	cardComponent.set_able(false)
	tripleHandleComponent.set_able(false)
	await Utils.run_and_wait_all(
		[
			freshComponent.start,
			upgradeComponent.start,
			coinComponent.start,
			sellComponent.start,
			exitComponent.start,
			levelComponent.start,
			bookComponent.start
		]
	)
	
	# 最后启动卡牌控件
	cardComponent.set_able(true)
	await Utils.run_and_wait_all([cardComponent.start])
	
	# 等待全部空闲
	while _is_all_idle() == false:
		await GameManager.mainScene.get_tree().process_frame
	
	# 开启三连检测
	tripleHandleComponent.set_able(true)
	
	# 等待全部空闲
	while _is_all_idle() == false:
		await GameManager.mainScene.get_tree().process_frame
	
	# 触发回合开始效果
	round_started.emit()
	
func _is_all_idle() -> bool:
	return get_card_component().get_desk_card_collection().is_all_idle() and \
	get_card_component().get_hand_card_collection().is_all_idle() and \
	get_card_component().get_shop_card_collection().is_all_idle() and \
	GameManager.mainScene.get_player_component().get_animation_component().is_idle()

var _overlay: ColorRect = null
var overlay_times: int = 0 # 叠加次数
var time_times: int = 0 # 叠加次数
func open_overlay() -> void:
	overlay_times += 1
	if is_instance_valid(_overlay):
		return
	# 创建遮罩
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.4)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.name = "Overlay"
	self.add_child(_overlay)
	_overlay.global_position = Vector2.ZERO

func stop_time() -> void:
	time_times += 1
	# 停止时间
	if exitComponent.is_stopping() == false:
		exitComponent.stop()
	
func close_overlay() -> void:
	overlay_times -= 1
	if overlay_times == 0:
		if is_instance_valid(_overlay):
			_overlay.queue_free()
			self.remove_child(_overlay)

func goon_time() -> void :
	time_times -= 1
	if time_times == 0:
		# 开始时间
		if exitComponent.is_stopping() == true:
			exitComponent.go_on()
