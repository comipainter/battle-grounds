shader_type canvas_item;

// === Shape Parameters ===
// Top arch parameters
uniform float _ArchHeight : hint_range(0.0, 0.5) = 0.15;
uniform float _ArchCurve : hint_range(0.5, 8.0) = 2.0;
// Side mask parameters (diagonal from corners inward)
uniform float _SideMaskWidth : hint_range(0.0, 0.5) = 0.1;
// Bottom trim parameters
uniform float _BottomTrim : hint_range(0.0, 0.5) = 0.0;

// SDF for the arch-top shape with side masks
float shape_sdf(vec2 uv) {
	// Godot UV: (0,0) is Top-Left, (1,1) is Bottom-Right
	vec2 p = uv - vec2(0.5, 0.0);  // x: [-0.5, 0.5], y: [0, 1]

	// === Top Arch (upper half of an ellipse) ===
	// The ellipse is centered at (0, _ArchHeight) with:
	// - a = 0.5 (horizontal radius, half of image width)
	// - b = _ArchHeight (vertical radius, controlled by _ArchHeight)

	float a = 0.5;  // horizontal radius
	float b = _ArchHeight;  // vertical radius

	// For a point (x, y), the ellipse equation is: (x/a)^2 + ((y-b)/b)^2 = 1
	// Solving for y at the top half: y = b - b * sqrt(1 - (x/a)^2)

	float x_ratio = p.x / a;
	float inside_sqrt = 1.0 - x_ratio * x_ratio;

	float arch_y;
	if (inside_sqrt < 0.0) {
		// Outside the ellipse horizontally
		arch_y = 0.0;
	} else {
		// Top half of ellipse
		arch_y = b - b * pow(inside_sqrt, 0.5 / _ArchCurve);
	}

	// Distance from arch curve (positive = inside/below the arch)
	float top_dist = p.y - arch_y;

	// Bottom boundary (with trim)
	float bottom_dist = 1.0 - _BottomTrim - uv.y;

	return min(top_dist, bottom_dist);
}

// Side mask: diagonal lines from corners inward (hard edge)
// Starts below the arch so it doesn't cut off the arch top
float side_mask(vec2 uv) {
	// Left side: diagonal from top-left corner going down-right
	// Right side: diagonal from top-right corner going down-left

	float left_dist = uv.x;  // Distance from left edge
	float right_dist = 1.0 - uv.x;  // Distance from right edge

	// Calculate the diagonal threshold for each side
	// At y=_ArchHeight (below arch), mask starts at x=0
	// At y=1 (bottom), mask extends to x=_SideMaskWidth
	float arch_bottom = _ArchHeight;
	float adjusted_y = max(0.0, uv.y - arch_bottom) / (1.0 - arch_bottom);
	float left_threshold = adjusted_y * _SideMaskWidth;
	float right_threshold = adjusted_y * _SideMaskWidth;

	// Hard edge: 1 if inside, 0 if outside
	float left_mask = step(left_threshold, left_dist);
	float right_mask = step(right_threshold, right_dist);

	return min(left_mask, right_mask);
}

void fragment() {
	vec2 uv = UV;
	float dist = shape_sdf(uv);

	// Hard edge for arch shape
	float arch_mask = step(0.0, dist);

	// Apply side mask
	float side = side_mask(uv);

	// Combine masks
	float final_mask = arch_mask * side;

	// Discard fully transparent pixels
	if (final_mask < 0.001) {
		discard;
	}

	COLOR.rgb = texture(TEXTURE, uv).rgb;
	COLOR.a = final_mask;
}
