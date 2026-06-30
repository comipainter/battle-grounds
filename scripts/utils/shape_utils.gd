class_name ShapeUtils

static func is_point_in_rect_area(point: Vector2, collision_shape: CollisionShape2D) -> bool:
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape as RectangleShape2D
		
		# 构建一个 Rect2：起点是左上角(-extents)，大小是长宽(extents * 2)
		var rect = Rect2(-rect_shape.extents, rect_shape.extents * 2)
		
		# 转换为本地坐标后判断
		var local_point = collision_shape.to_local(point)
		return rect.has_point(local_point)
	return false

static func is_point_in_rect(point: Vector2, top_left: Vector2, bottom_right: Vector2) -> bool:
	if point.x >= top_left.x and point.x <= bottom_right.x and \
	   point.y >= top_left.y and point.y <= bottom_right.y:
		return true
	return false
