extends ContainerComponent
class_name HandContainerComponent

## 曲线效果参数
@export var curve_height: float = 80.0  ## 曲线最大高度
@export var curve_power: float = 1.5    ## 曲线弯曲程度（越大越弯曲）
@export var max_rotation: float = 15.0  ## 最大倾斜角度（度数）

@export var Max_Z_Index: int = 10

## 每张卡牌的基础Y偏移（用于曲线效果）
var _card_y_offsets: Dictionary = {}

func _ready() -> void:
	super._ready()
	# 连接排序完成信号，在布局完成后应用曲线
	sort_children.connect(_on_sort_children)

func _update_seperation_size() -> void:
	var childCount: int = get_child_count()
	var final_separation: int = separationSize
	
	#if childCount > 15:
		#final_separation = 35
		
	if childCount > 20:
		final_separation = 10
	
	elif childCount > 10:
		# 11~15张：以10张时的值(60)为基准，每多1张缩减5
		var base_at_10 = separationSize - (7 - 4) * 20 - (10 - 7) * 10
		final_separation = base_at_10 - (childCount - 10) * 5
		
	elif childCount > 7:
		# 8~10张：以7张时的值(90)为基准，每多1张缩减10
		var base_at_7 = separationSize - (7 - 4) * 20
		final_separation = base_at_7 - (childCount - 7) * 10
		
	elif childCount > 4:
		# 5~7张：每多1张缩减20
		final_separation = separationSize - (childCount - 4) * 20
	
	add_theme_constant_override("separation", final_separation)

func _on_sort_children() -> void:
	_update_curve_positions()

func add_card(card: Card) -> void:
	super.add_card(card)
	#card.mouse_entered.connect(_card_hover_started)
	#card.mouse_exited.connect(_card_hover_ended)
	# 使用call_deferred确保布局完成后再更新曲线
	call_deferred("_update_curve_positions")

#func _card_hover_started(position: Vector2, card: Card) -> void:
	## 设置卡牌z_index为最上层
	#card.z_index = Max_Z_Index
	#
#func _card_hover_ended(card: Card) -> void:
	## 设置卡牌z_index为最上层
	#card.z_index = 1

func remove_card(card: Card) -> void:
	super.remove_card(card)
	# 清理记录的偏移
	var target = card.get_move_component().get_target()
	if target and _card_y_offsets.has(target):
		_card_y_offsets.erase(target)
	call_deferred("_update_curve_positions")

func _card_dragging(card: Card) -> void:
	super._card_dragging(card)
	call_deferred("_update_curve_positions")

func _card_end_drag(card: Card) -> void:
	super._card_end_drag(card)
	call_deferred("_update_curve_positions")

## 更新曲线位置 - 通过修改target的position.y实现
## 注意：需要在_sort_children后调用，或使用call_deferred确保布局完成
func _update_curve_positions() -> void:
	var child_count = get_child_count()
	if child_count == 0:
		return

	# 单张卡牌时不需要偏移
	if child_count == 1:
		var target = get_child(0) as Control
		if is_instance_valid(target):
			target.position.y = 0.0
			target.rotation = 0.0
			_card_y_offsets[target] = 0.0
		return

	# 卡牌数较少时缩减偏移量（基于卡牌数量的缩放因子）
	# 2张时scale为0.5，7张时scale接近1.0
	var count_scale = min(1.0, float(child_count) / 7.0)

	# 遍历所有target，根据其在容器中的位置计算Y偏移
	for i in child_count:
		var target = get_child(i) as Control
		if not is_instance_valid(target):
			continue

		# 计算归一化位置 (0到1，中间为0.5)
		var normalized_pos = float(i) / float(child_count - 1)

		# 使用余弦曲线：中心最高，边缘也有一定高度
		# cos((x-0.5)*PI) 在x=0.5时为1(最高)，x=0和x=1时为-1(最低)
		# 归一化到 [edge_ratio, 1.0] 范围
		var edge_ratio = 0.1  # 边缘高度占最大高度的比例
		var cosine_value = cos((normalized_pos - 0.5) * PI)  # 范围 [-1, 1]
		# 映射到 [edge_ratio, 1.0]
		var y_offset = curve_height * lerp(edge_ratio, 1.0, (cosine_value + 1.0) / 2.0)

		# 应用数量缩放因子
		y_offset *= count_scale

		# 通过修改target的position.y来实现曲线效果
		# HBoxContainer会设置X位置，但我们可以覆盖Y位置
		target.position.y = -y_offset

		# 计算倾斜角度：两端的卡牌向内倾斜，中间的卡牌rotation为0
		# normalized_pos: 0在最左边，1在最右边，0.5在中间
		# 左边的卡牌(normalized_pos < 0.5)应该有正rotation(向右倾斜)
		# 右边的卡牌(normalized_pos > 0.5)应该有负rotation(向左倾斜)
		var rotation_offset = (0.5 - normalized_pos) * 2.0  # 范围: -1到1
		# 同样应用数量缩放因子
		var target_rotation_deg = -rotation_offset * max_rotation * count_scale
		# 将度数转换为弧度
		target.rotation = deg_to_rad(target_rotation_deg)

		# 记录偏移供其他地方使用
		_card_y_offsets[target] = y_offset

## 获取某张卡牌的曲线Y偏移
func get_card_curve_offset(card: Card) -> float:
	var target = card.get_move_component().get_target()
	if target and _card_y_offsets.has(target):
		return _card_y_offsets[target]
	return 0.0

## 获取所有卡牌的总曲线偏移信息（用于调试或其他用途）
func get_all_curve_offsets() -> Dictionary:
	return _card_y_offsets.duplicate()
