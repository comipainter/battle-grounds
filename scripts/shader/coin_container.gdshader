shader_type canvas_item;

uniform float white_threshold: hint_range(0.0, 1.0) = 0.95;

void fragment() {
	vec4 color = COLOR;

	// 检测是否为白色（RGB都接近threshold）
	bool is_white = color.r > white_threshold &&
	                color.g > white_threshold &&
	                color.b > white_threshold;

	// 如果是白色，设置为透明
	if (is_white) {
		color.a = 0.0;
	}

	COLOR = color;
}
