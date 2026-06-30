shader_type canvas_item;
render_mode blend_add;

// === Rectangle Parameters (edge coordinates) ===
uniform float _Left : hint_range(0.0, 1.0) = 0.2;
uniform float _Right : hint_range(0.0, 1.0) = 0.8;
uniform float _Top : hint_range(0.0, 1.0) = 0.3;
uniform float _Bottom : hint_range(0.0, 1.0) = 0.7;

// === Glow Parameters ===
uniform vec4 _GlowColor : source_color = vec4(1.0, 0.8, 0.3, 1.0);
uniform float _GlowIntensity : hint_range(0.0, 5.0) = 1.5;
uniform float _GlowFalloff : hint_range(0.1, 30.0) = 3.0;
uniform float _InnerBrightness : hint_range(0.0, 2.0) = 1.0;

// === Animation ===
uniform float _PulseSpeed : hint_range(0.0, 20.0) = 0.0;
uniform float _PulseAmount : hint_range(0.0, 0.5) = 0.0;

// SDF for axis-aligned rectangle defined by four edge coordinates
float rect_sdf(vec2 p, float left, float right, float top, float bottom) {
	vec2 d = abs(p - vec2((left + right) * 0.5, (top + bottom) * 0.5))
		- vec2((right - left) * 0.5, (bottom - top) * 0.5);
	return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void fragment() {
	vec2 uv = UV;

	// Calculate pulse effect
	float pulse = 1.0;
	if (_PulseSpeed > 0.0 && _PulseAmount > 0.0) {
		pulse = 1.0 + _PulseAmount * sin(TIME * _PulseSpeed);
	}

	// Apply pulse to edge coordinates (expand outward from center)
	vec2 center = vec2((_Left + _Right) * 0.5, (_Top + _Bottom) * 0.5);
	vec2 half_size = vec2((_Right - _Left) * 0.5, (_Bottom - _Top) * 0.5) * pulse;
	float left = center.x - half_size.x;
	float right = center.x + half_size.x;
	float top = center.y - half_size.y;
	float bottom = center.y + half_size.y;

	// Calculate SDF distance
	float dist = rect_sdf(uv, left, right, top, bottom);

	// Calculate glow using smooth falloff
	float glow = 0.0;

	if (dist < 0.0) {
		glow = _InnerBrightness;
	} else {
		glow = exp(-dist * _GlowFalloff);
	}

	glow *= _GlowIntensity;

	// Discard pixels outside glow range
	if (glow < 0.01) {
		discard;
	}

	COLOR = vec4(_GlowColor.rgb, _GlowColor.a * glow);
}
