@tool
extends Path2D
class_name HandNameLabel

@export var text: String = "Hello Godot!":  # 设置要显示的文字
	set(value):
		if text != value:
			text = value
			queue_redraw()

@export var label_settings: LabelSettings:  # 可以在此处指定字体、字号和颜色等
	set(value):
		if is_instance_valid(label_settings) and label_settings.changed.is_connected(queue_redraw):
			label_settings.changed.disconnect(queue_redraw)
		label_settings = value
		if is_instance_valid(label_settings):
			label_settings.changed.connect(queue_redraw)

var _line = TextLine.new()

func _draw() -> void:
	# 获取默认的字体、字号和颜色
	var font = ThemeDB.fallback_font
	var font_size = ThemeDB.fallback_font_size
	var font_color = Color.WHITE
	var outline_color: Color
	var outline_size: int = 0

	if is_instance_valid(label_settings):
		font = label_settings.font
		font_size = label_settings.font_size
		font_color = label_settings.font_color
		outline_color = label_settings.outline_color
		outline_size = label_settings.outline_size

	_line.clear()
	_line.add_string(text, font, font_size)

	var ts = TextServerManager.get_primary_interface()
	var glyphs = ts.shaped_text_get_glyphs(_line.get_rid())

	# 1. 第一次遍历：计算整段文字的总宽度
	var total_width = 0.0
	for glyph_data in glyphs:
		total_width += glyph_data.get("advance", 0.0)

	# 2. 从曲线中点开始绘制，让文字居中显示
	# 文字的视觉中心在 total_width / 2 的位置
	# 所以第一个字符的定位点应该从 curve_length/2 - total_width/2 开始
	var curve_length = curve.get_baked_length()
	var offset = curve_length / 2.0 - total_width / 2.0

	# 但是 offset 是第一个字符的左边位置
	# 文字视觉中心 = offset + total_width/2 = curve_length/2 ✓
	# 这个计算是正确的

	for glyph_data in glyphs:
		var advance = glyph_data.get("advance", 0.0)
		var glyph_rid = glyph_data["font_rid"]
		var glyph_index = glyph_data["index"]

		# 确保在曲线范围内才绘制
		if offset >= 0 and offset <= curve_length:
			# 沿着曲线采样当前位置和旋转角度
			var trans = curve.sample_baked_with_rotation(offset)
			draw_set_transform_matrix(trans)

			# 先绘制轮廓（如果有）
			if outline_size > 0:
				ts.font_draw_glyph_outline(glyph_rid, get_canvas_item(), font_size, outline_size, Vector2.ZERO, glyph_index, outline_color)

			# 绘制当前字符（字形）
			ts.font_draw_glyph(glyph_rid, get_canvas_item(), font_size, Vector2.ZERO, glyph_index, font_color)

		# 累加字形的宽度，继续绘制下一个字符
		offset += advance
