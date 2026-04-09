shader_type canvas_item;

// --- 圆角矩形参数 ---
uniform float corner_radius : hint_range(0.0, 0.5) = 0.1;
uniform float edge_softness : hint_range(0.0, 0.5) = 0.05;

void fragment() {
	// 1. 获取原始纹理颜色
	vec4 tex_color = texture(TEXTURE, UV);
	
	// 2. 计算圆角矩形的 SDF (有符号距离场)
	float half_size = 0.5;
    float r = corner_radius;
    // 计算到圆角矩形边界的距离
    vec2 dist_to_edge = abs(UV - 0.5) - (half_size - r);
    float sdf = length(max(dist_to_edge, 0.0)) + min(max(dist_to_edge.x, dist_to_edge.y), 0.0) - r;
	
	// 3. 计算遮罩透明度 (Alpha Mask)
	// 内部为 1.0, 边界附近渐变到 0.0, 外部为 0.0
	float alpha_mask = 1.0 - smoothstep(-edge_softness, 0.0, sdf);
	
	// 如果遮罩完全透明，可以直接丢弃像素以优化性能 (可选)
	COLOR = tex_color;
	COLOR.a *= alpha_mask;
}