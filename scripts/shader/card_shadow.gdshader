shader_type canvas_item;

// --- 可以在编辑器里直接调节的参数 ---
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5); // 阴影颜色与透明度
uniform vec2 shadow_offset = vec2(20.0, 20.0); // 阴影偏移距离
uniform float shadow_blur : hint_range(0.0, 100.0) = 20.0; // 阴影模糊程度

void fragment() {
	// 1. 获取当前像素原本的纹理颜色
	vec4 original_color = texture(TEXTURE, UV);

	// 2. 对阴影区域进行模糊采样，模拟 StyleBoxFlat 的 shadow_size 效果
	float blur_radius = shadow_blur * SCREEN_PIXEL_SIZE.x;
	float shadow_alpha = 0.0;

	// 多方向采样实现模糊
	for (float angle = 0.0; angle < 6.28318; angle += 0.785398) { // 8个方向
		vec2 sample_offset = vec2(cos(angle), sin(angle)) * blur_radius;
		shadow_alpha += texture(TEXTURE, UV + sample_offset).a;
	}
	shadow_alpha /= 8.0;

	// 3. 混合最终颜色，将原图变成阴影颜色
	COLOR = shadow_color * shadow_alpha;
}