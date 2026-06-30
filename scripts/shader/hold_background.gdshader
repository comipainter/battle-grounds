shader_type canvas_item;

// --- 亮度和饱和度过滤参数 ---
uniform float brightness_threshold : hint_range(0.0, 1.0) = 0.9;
uniform float saturation_threshold : hint_range(0.0, 1.0) = 0.15;

// --- 椭圆剔除参数 ---
// 椭圆中心点的 UV 坐标 (范围 0.0 到 1.0)
uniform vec2 ellipse_center = vec2(0.5, 0.5);
// 椭圆在 X 和 Y 方向上的半径 (范围 0.0 到 1.0，相对于整个贴图的比例)
uniform vec2 ellipse_radius = vec2(0.2, 0.3);

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec3 rgb = texture_color.rgb;
	
	// 1. 计算亮度
	float brightness = dot(rgb, vec3(0.299, 0.587, 0.114));
	
	// 2. 计算饱和度
	float max_c = max(rgb.r, max(rgb.g, rgb.b));
	float min_c = min(rgb.r, min(rgb.g, rgb.b));
	float delta = max_c - min_c;
	float saturation = (max_c == 0.0) ? 0.0 : delta / max_c;
	
	// 3. 判断当前像素是否在椭圆内
	// 计算当前 UV 到椭圆中心的距离向量
	vec2 dist_vec = UV - ellipse_center;
	// 利用椭圆公式进行归一化：如果结果小于等于 1.0，说明在椭圆内部
	float ellipse_check = (dist_vec.x * dist_vec.x) / (ellipse_radius.x * ellipse_radius.x) + 
						  (dist_vec.y * dist_vec.y) / (ellipse_radius.y * ellipse_radius.y);
	bool is_in_ellipse = ellipse_check <= 1.0;
	
	// 综合判断：满足（亮度高且饱和度低）或者（在椭圆内）任意一个条件，都将其变为透明
	if ((brightness > brightness_threshold && saturation < saturation_threshold) || is_in_ellipse) {
		texture_color.a = 0.0;
	}
	
	COLOR = texture_color;
}