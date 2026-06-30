shader_type canvas_item;

uniform float blend_factor: hint_range(0.0, 1.0) = 0.0;
uniform vec4 gray_overlay: source_color = vec4(0, 0, 0, 0.5);
uniform bool pre_deactivate = false;
uniform vec4 glow_color: source_color = vec4(1.0, 0.85, 0.2, 1.0);
uniform float glow_radius: hint_range(0.0, 1.0) = 1.0;
uniform float glow_intensity: hint_range(0.0, 1.0) = 0.9;
uniform float glow_speed: hint_range(0.1, 20.0) = 6.0;

void fragment() {
	vec4 color = COLOR;

	// 预失活：圆形泛光并闪烁
	if (pre_deactivate) {
		float dist = distance(UV, vec2(0.5));
		float glow = 1.0 - smoothstep(0.0, glow_radius, dist);
		float blink = 0.5 + 0.5 * sin(TIME * glow_speed);
		color.rgb = mix(color.rgb, glow_color.rgb, glow * blink * glow_intensity);
	}

	// 未激活：灰色遮罩
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 grayed = mix(vec3(gray), gray_overlay.rgb, gray_overlay.a);
	color.rgb = mix(color.rgb, grayed, blend_factor);

	COLOR = color;
}
