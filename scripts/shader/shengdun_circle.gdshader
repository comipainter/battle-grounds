shader_type canvas_item;
render_mode blend_add;

// === Ellipse Parameters ===
uniform vec2 _Center = vec2(0.5, 0.5);
uniform vec2 _Size = vec2(0.3, 0.2);  // (width, height) as radius
uniform float _Rotation : hint_range(0.0, 6.28) = 0.0;  // Rotation in radians

// === Glow Parameters ===
uniform vec4 _GlowColor : source_color = vec4(1.0, 0.8, 0.3, 1.0);
uniform float _GlowIntensity : hint_range(0.0, 5.0) = 1.5;
uniform float _GlowFalloff : hint_range(0.1, 10.0) = 3.0;  // Higher = sharper edge
uniform float _EdgeWidth : hint_range(0.001, 0.1) = 0.02;  // Edge ring thickness
uniform float _Cutoff : hint_range(0.0, 1.0) = 0.05;  // Discard glow below this threshold

// === Animation ===
uniform float _PulseSpeed : hint_range(0.0, 10.0) = 0.0;
uniform float _PulseAmount : hint_range(0.0, 0.5) = 0.0;

// SDF for ellipse with rotation
float ellipse_sdf(vec2 p, vec2 center, vec2 size, float rotation) {
	// Translate to center
	vec2 d = p - center;

	// Apply rotation
	float c = cos(-rotation);
	float s = sin(-rotation);
	vec2 rotated = vec2(
		d.x * c - d.y * s,
		d.x * s + d.y * c
	);

	// Ellipse SDF: length(rotated / size) - 1
	// This gives 0 at the edge, negative inside, positive outside
	vec2 scaled = rotated / size;
	return length(scaled) - 1.0;
}

void fragment() {
	vec2 uv = UV;

	// Calculate pulse effect
	float pulse = 1.0;
	if (_PulseSpeed > 0.0 && _PulseAmount > 0.0) {
		pulse = 1.0 + _PulseAmount * sin(TIME * _PulseSpeed);
	}

	// Apply pulse to size
	vec2 animated_size = _Size * pulse;

	// Calculate SDF distance
	float dist = ellipse_sdf(uv, _Center, animated_size, _Rotation);

	// Edge glow: brightest at the ellipse edge, fades inward and outward
	// dist ≈ 0 at edge, negative inside, positive outside
	float edge = abs(dist);
	float glow = exp(-edge / _EdgeWidth) * _GlowIntensity;

	// Discard pixels outside glow range to avoid showing ColorRect bounds
	if (glow < _Cutoff) {
		discard;
	}

	// Output color with glow
	COLOR = vec4(_GlowColor.rgb, _GlowColor.a * glow);
}
