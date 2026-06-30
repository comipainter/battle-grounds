shader_type canvas_item;

// ========== 椭圆裁剪效果（常驻）==========
uniform vec2 ellipse_center = vec2(0.5, 0.5);
uniform float ellipse_scale_x : hint_range(0.1, 2.0) = 1.0;
uniform float ellipse_scale_y : hint_range(0.1, 2.0) = 1.0;
uniform float global_scale : hint_range(0.1, 2.0) = 1.0;
uniform float edge_feather : hint_range(0.0, 0.5) = 0.1; // 边缘羽化宽度

// ========== 波纹扭曲效果（可选）==========
uniform bool enable_wave = false;
uniform float wave_speed : hint_range(0.0, 20.0) = 5.0;
uniform float wave_frequency : hint_range(10.0, 200.0) = 100.0;
uniform float wave_amplitude : hint_range(0.0, 0.2) = 0.05;
uniform vec4 wave_tint : source_color = vec4(0.5, 0.7, 1.0, 1.0);
uniform float wave_tint_intensity : hint_range(0.0, 1.0) = 0.3;
uniform vec4 wave_overlay : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float wave_overlay_intensity : hint_range(0.0, 1.0) = 0.15;

// ========== 溶解效果（可选）==========
uniform bool enable_dissolve = false;
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 dissolve_edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float dissolve_edge_width : hint_range(0.0, 0.3) = 0.08;

// 简单的噪声函数（用于溶解效果）
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = UV;
	float wave_offset = 0.0;

	// 波纹扭曲效果（如果启用）
	if (enable_wave) {
		vec2 centered_uv = UV - vec2(0.5);
		float dist = length(centered_uv);
		wave_offset = sin(dist * wave_frequency - TIME * wave_speed);
		uv = UV + vec2(wave_offset * wave_amplitude);
	}

	// 椭圆裁剪效果（常驻）+ 边缘羽化
	vec2 centered_uv = (UV - ellipse_center) * global_scale;
	vec2 normalized_uv = vec2(
		centered_uv.x / ellipse_scale_x,
		centered_uv.y / ellipse_scale_y
	);

	float ellipse_dist = dot(normalized_uv, normalized_uv);

	// 边缘羽化：在椭圆边缘附近渐变透明
	float edge_start = 1.0 - edge_feather;
	float edge_alpha = smoothstep(1.0, edge_start, ellipse_dist);

	// 完全在椭圆外则丢弃
	if (ellipse_dist > 1.0) {
		discard;
	}

	COLOR.rgb = texture(TEXTURE, uv).rgb;
	float alpha = texture(TEXTURE, uv).a;

	// 溶解效果（如果启用）
	if (enable_dissolve) {
		// 使用多层噪声生成更自然的溶解效果
		float n = noise(UV * 8.0) * 0.5 + noise(UV * 16.0) * 0.3 + noise(UV * 32.0) * 0.2;

		float dissolve_edge = dissolve_amount + dissolve_edge_width;
		float dissolve_alpha = smoothstep(dissolve_amount, dissolve_edge, n);

		// 边缘发光
		float edge = smoothstep(dissolve_amount, dissolve_amount + dissolve_edge_width, n);
		edge = edge * (1.0 - smoothstep(dissolve_amount + dissolve_edge_width * 0.5, dissolve_edge, n));

		COLOR.rgb = mix(COLOR.rgb, dissolve_edge_color.rgb, edge);
		alpha *= dissolve_alpha;
	}

	// 波纹时叠加颜色
	if (enable_wave) {
		float wave_alpha = (wave_offset + 1.0) * 0.5 * wave_tint_intensity;
		COLOR.rgb = mix(COLOR.rgb, wave_tint.rgb, wave_alpha);
		// 淡白色遮罩
		COLOR.rgb = mix(COLOR.rgb, wave_overlay.rgb, wave_overlay_intensity);
	}

	COLOR.a = alpha * edge_alpha;
}
