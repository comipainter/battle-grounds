shader_type canvas_item;

// --- 动画与颜色参数 ---
uniform float speed : hint_range(0.1, 20.0) = 5.0; 
uniform float intensity : hint_range(0.0, 5.0) = 1.5; 
uniform vec4 gold_color : source_color = vec4(1.0, 0.84, 0.0, 1.0); // 基础金色
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 0.9, 1.0); // 高光白色
uniform float gold_opacity : hint_range(0.0, 1.0) = 0.2; 
uniform bool enable = false; // 默认开启以便观察

// --- 圆角矩形参数 ---
uniform float corner_radius : hint_range(0.0, 0.5) = 0.1;
uniform float edge_softness : hint_range(0.0, 0.5) = 0.05;
uniform float edge_glow_width : hint_range(0.0, 0.2) = 0.05; // 边缘辉光宽度

void fragment() {
	// 1. 获取原始纹理颜色
	vec4 tex_color = texture(TEXTURE, UV);
	
	// 如果原图完全透明，直接丢弃（优化性能）
	if (tex_color.a < 0.01) {
		discard;
	}

	// 2. 计算圆角矩形的 SDF (有符号距离场)
	float half_size = 0.5;
    float r = corner_radius;
    vec2 dist_to_edge = abs(UV - 0.5) - (half_size - r);
    float sdf = length(max(dist_to_edge, 0.0)) + min(max(dist_to_edge.x, dist_to_edge.y), 0.0) - r;
	
	// 3. 计算主遮罩透明度 (Alpha Mask)
	float alpha_mask = 1.0 - smoothstep(-edge_softness, 0.0, sdf);
	
	// 如果遮罩完全透明，丢弃
	if (alpha_mask < 0.01) {
		discard;
	}

	// 基础输出颜色
	vec3 final_color = tex_color.rgb;
	float final_alpha = tex_color.a * alpha_mask;

	if (enable) {
		float time = TIME * speed;
		
		// --- 效果 A: 流动扫光 (Moving Shine) ---
		// 创建一道从左上到右下移动的光带
		// dot(UV, vec2(1.0, 1.0)) 创建对角线梯度
		float move_pos = fract(time * 0.2 - 0.5); // 0.0 到 1.0 循环
		float dist_to_shine = abs(dot(UV, normalize(vec2(1.0, 1.0))) - move_pos);
		// 将距离转换为锐利的高光
		float shine_band = 1.0 - smoothstep(0.0, 0.15, dist_to_shine);
		// 让高光带两端变弱，形成椭圆状
		shine_band *= smoothstep(0.0, 0.2, move_pos) * (1.0 - smoothstep(0.8, 1.0, move_pos));
		
		// --- 效果 B: 整体闪烁 (Pulsing) ---
		float pulse = 0.5 + 0.5 * sin(time * 3.0);
		
		// --- 效果 C: 边缘辉光 (Edge Glow) ---
		// 利用 SDF 在边缘内部产生辉光
		float edge_mask = 1.0 - smoothstep(0.0, edge_glow_width, sdf);
		edge_mask *= alpha_mask; // 确保只在圆角范围内

		// --- 颜色混合计算 ---
		
		// 1. 计算扫光层的颜色 (白色高光 + 金色 tint)
		vec3 shine_col = mix(highlight_color.rgb, gold_color.rgb, 0.5);
		vec3 add_shine = shine_col * shine_band * intensity * 0.8;
		
		// 2. 计算整体泛金层 (基于原图亮度，避免死黑区域过亮)
		float brightness = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
		vec3 ambient_gold = gold_color.rgb * pulse * (brightness * 0.5 + 0.2);
		
		// 3. 计算边缘发光层
		vec3 edge_glow = gold_color.rgb * edge_mask * 0.8;

		// --- 最终合成 (使用 Additive 混合模式模拟发光) ---
		// 基础色 + 扫光 + 环境金 + 边缘光
		// 注意：这里直接相加可能会过曝，可以根据需要调整系数
		final_color += add_shine * gold_opacity;
		final_color += ambient_gold * gold_opacity * 0.4;
		final_color += edge_glow * gold_opacity * 0.5;
		
		// 可选：限制最大亮度防止过度发白 (Clamp)
		final_color = clamp(final_color, 0.0, 1.5); // 允许略微超过1.0以获得HDR感，如果在Godot中开启了HDR
	}

	COLOR = vec4(final_color, final_alpha * COLOR.a);
}