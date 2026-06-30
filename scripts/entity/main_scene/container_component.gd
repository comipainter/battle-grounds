extends HBoxContainer
class_name ContainerComponent

var separationSize: int = 150
var normal_target_size: Vector2 = Vector2(100, 0)
var drag_target_size: Vector2 = Vector2(0, 0)

var sortable: bool = false
func is_sort_able() -> bool:
	return sortable
func set_sort_able(_able: bool) -> void:
	sortable = _able

func _ready() -> void:
	_set_seperation_size()
	
func _set_seperation_size() -> void:
	self.add_theme_constant_override("separation", separationSize)

func _update_seperation_size() -> void:
	var childCount: int = get_child_count()
	if childCount > 4:
		add_theme_constant_override("separation", separationSize - (childCount-4)*10)
	else:
		add_theme_constant_override("separation", separationSize)
	
	
	
func add_card(card: Card) -> void:
	var target = Control.new()
	target.custom_minimum_size  = normal_target_size

	if is_sort_able():
		# 根据卡牌位置找到合适的插入索引
		var insert_index := get_child_count()
		for i in get_child_count():
			var existing_target := get_child(i) as Control
			# 获取该target对应的卡牌（通过检查target的全局位置）
			# 由于卡牌会跟随target，我们比较卡牌位置与现有target位置
			if card.global_position.x < existing_target.global_position.x:
				insert_index = i
				break

		add_child(target)
		if insert_index <= get_child_count() - 1:
			move_child(target, insert_index)
	else:
		add_child(target)

	card.follow(target)
	_update_seperation_size()
	card.dragging.connect(_card_dragging)
	card.drag_ended.connect(_card_end_drag)
	
func _card_dragging(card: Card) -> void:
	if not is_sort_able():
		card.get_move_component().get_target().custom_minimum_size = drag_target_size
		return

	var insert_index: int = get_child_count()
	for target in get_children():
		if card.global_position.x < target.global_position.x:
			insert_index = target.get_index()
			break
			
	var curr_target: Control = card.get_move_component().get_target()
	if insert_index - 1 == curr_target.get_index(): # 现在位置不用变
		pass
	else:
		move_child(curr_target, insert_index)
	curr_target.custom_minimum_size = drag_target_size

func _card_end_drag(card: Card) -> void:
	card.get_move_component().get_target().custom_minimum_size = normal_target_size
	
func remove_card(card: Card) -> void:
	var target: Control = card.get_move_component().get_target()
	if is_instance_valid(target):
		remove_child(target) # 保证target立刻删除
		target.queue_free()
	card.dragging.disconnect(_card_dragging)
	card.drag_ended.disconnect(_card_end_drag)
	_update_seperation_size()
	
func sort(cards: CardCollection) -> void:
	if is_sort_able() == false:
		push_error("sort container when sortable == false")
		return

	var card_array := cards.get_array()
	# 根据卡牌的全局位置排序（按x坐标从小到大）
	card_array.sort_custom(func(a: Card, b: Card) -> bool:
		return a.global_position.x < b.global_position.x
	)

	# 按排序后的顺序重新排列target
	for i in card_array.size():
		var card := card_array[i]
		var target := card.get_move_component().get_target()
		if is_instance_valid(target) and target.get_parent() == self:
			move_child(target, i)
		
