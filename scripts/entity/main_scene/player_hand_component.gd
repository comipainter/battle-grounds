extends Control
class_name PlayerHandComponent

# 导出变量，方便在编辑器里直接拖入我们刚才创建的曲线资源
@export var spread_curve: Curve
@export var height_curve: Curve

# 手牌布局的参数配置
@export var separation_size: int = 150
@export var normal_target_size: Vector2 = Vector2(100, 0)
@export var big_target_size: Vector2 = Vector2(200, 0)
@export var max_rotation: float = 15.0       # 最两边卡牌的最大旋转角度
@export var y_offset: float = 300.0          # 整体手牌在Y轴上的基准位置

var sortable: bool = false

func is_sort_able() -> bool:
	return sortable

func set_sort_able(_able: bool) -> void:
	sortable = _able

func _ready():
	# 如果忘记在编辑器里赋值曲线，这里给个保底防止报错
	if not spread_curve:
		spread_curve = Curve.new()
		spread_curve.add_point(Vector2(0, 0))
		spread_curve.add_point(Vector2(1, 1))
	if not height_curve:
		height_curve = Curve.new()
		height_curve.add_point(Vector2(0, 1))
		height_curve.add_point(Vector2(0.5, 0))
		height_curve.add_point(Vector2(1, 1))

	update_hand_layout()

# 每当手牌数量发生变化（抽卡/打牌）时，调用这个函数
func update_hand_layout():
	var targets = get_children()
	var target_count = targets.size()
	if target_count == 0:
		return

	for i in range(target_count):
		var target = targets[i]

		# 1. 核心算法：归一化比例 (ratio)，范围在 0.0 到 1.0 之间
		var ratio = float(i) / float(max(1, target_count - 1))
		if target_count == 1:
			ratio = 0.5 # 只有一张牌时，让它处于正中间

		# 2. 利用曲线资源计算位置和旋转
		# 从曲线中采样出当前卡牌的比例对应的 X 偏移比例和 Y 高度比例
		var x_ratio = spread_curve.sample(ratio)
		var y_ratio = height_curve.sample(ratio)

		# 计算实际的像素坐标
		# 整体宽度由卡牌数量和间距决定，x_ratio 决定了它在其中的横向位置
		var total_width = (target_count - 1) * separation_size + normal_target_size.x
		var start_x = -total_width / 2.0 # 让整副手牌居中显示
		var target_x = start_x + x_ratio * total_width
		var target_y = y_ratio * 100.0 + y_offset # 100.0 是弧度的最大落差值

		# 计算旋转角度 (从 -max_rotation 到 +max_rotation)
		var target_rotation = remap(ratio, 0.0, 1.0, -max_rotation, max_rotation)

		# 3. 【进阶必选】加入 Tween 平滑过渡动画
		# 这样卡牌不会瞬间跳过去，而是优雅地滑到新位置
		var tween = create_tween()
		tween.set_parallel(true) # 允许同时执行多个属性的动画
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)

		# 平滑插值目标位置和目标旋转
		tween.tween_property(target, "position", Vector2(target_x, target_y), 0.3)
		tween.tween_property(target, "rotation_degrees", target_rotation, 0.3)

func add_card(card: Card) -> void:
	var target = Control.new()
	target.custom_minimum_size = normal_target_size

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
		if insert_index < get_child_count() - 1:
			move_child(target, insert_index)
	else:
		add_child(target)

	card.follow(target)
	card.get_move_component().dragging.connect(_card_dragging)
	card.get_move_component().end_drag.connect(_card_end_drag)
	update_hand_layout()

func _card_dragging(card: Card) -> void:
	if not is_sort_able():
		card.get_move_component().get_target().custom_minimum_size = big_target_size
		update_hand_layout()
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
	curr_target.custom_minimum_size = big_target_size
	update_hand_layout()

func _card_end_drag(card: Card) -> void:
	card.get_move_component().get_target().custom_minimum_size = normal_target_size
	update_hand_layout()

func remove_card(card: Card) -> void:
	card.get_move_component().get_target().queue_free()
	card.get_move_component().dragging.disconnect(_card_dragging)
	card.get_move_component().end_drag.disconnect(_card_end_drag)
	update_hand_layout()

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

	update_hand_layout()
