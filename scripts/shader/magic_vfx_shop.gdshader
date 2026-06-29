shader_type canvas_item;
render_mode blend_add; // 开启加法混合，适合制作发光特效

// === Shape Parameters ===
// 拱形参数
uniform float _ArchHeight : hint_range(0.0, 1.0) = 0.15;  // 高度
uniform float _ArchTopHeight : hint_range(0.0, 1.0) = 0.15; // 顶点高度
uniform float _ArchWidth : hint_range(0.0, 1.0) = 0.5;    // 宽度
uniform float _ArchCurve : hint_range(0.5, 8.0) = 2.0;    // 曲度
// 左斜线参数
uniform float _LeftSideX : hint_range(0.0, 1.0) = 0.1;    // 水平位置
uniform float _LeftSideSlope : hint_range(-5.0, 5.0) = 1.0; // 斜率
// 右斜线参数
uniform float _RightSideX : hint_range(0.0, 1.0) = 0.9;   // 水平位置
uniform float _RightSideSlope : hint_range(-5.0, 5.0) = -1.0; // 斜率
// 底边参数
uniform float _BottomTrim : hint_range(0.0, 0.5) = 0.0;

// === Glow Parameters ===
uniform vec4 _GlowColor : source_color = vec4(0.4, 0.6, 1.0, 1.0);
uniform float _GlowIntensity : hint_range(0.0, 5.0) = 1.5;
uniform float _GlowFalloff : hint_range(0.1, 100.0) = 3.0;

// === Animation ===
uniform float _PulseSpeed : hint_range(0.0, 10.0) = 1.0;
uniform float _PulseAmount : hint_range(0.0, 0.5) = 0.1;

bool is_in_arch(vec2 uv) {
	vec2 p = uv - vec2(0.5, 0.0);
	float a = _ArchWidth;  // 使用宽度参数
	float b = _ArchHeight;
	float top_h = _ArchTopHeight;
	float x_ratio = p.x / a;
	float inside_sqrt = 1.0 - x_ratio * x_ratio;

	if (inside_sqrt < 0.0) {
		return false;
	}
	float arch_y = 1.0 - top_h - (b - top_h) * pow(inside_sqrt, 0.5 / _ArchCurve);
	return p.y - arch_y > 0.0;
}

bool is_in_left_line(vec2 uv) {
	float threshold_x = _LeftSideSlope * uv.y + _LeftSideX;
	return uv.x - threshold_x > 0.0;
}

bool is_in_right_line(vec2 uv) {
	float threshold_x = _RightSideSlope * uv.y + _RightSideX;
	return threshold_x - uv.x > 0.0;
}

// SDF for bottom edge
bool is_in_bottom_sdf(vec2 uv) {
	return 1.0 - _BottomTrim - uv.y > 0.0;
}

bool is_in_region(vec2 uv){
	return is_in_arch(uv) && is_in_left_line(uv) && is_in_right_line(uv) && is_in_bottom_sdf(uv);
}

float arch_sdf(vec2 uv) {
	vec2 p = uv - vec2(0.5, 0.0);
	float a = _ArchWidth;
	float b = _ArchHeight;
	float top_h = _ArchTopHeight;
	
	// 计算当前 x 坐标下，拱形轮廓的理论 y 值
	float x_ratio = p.x / a;
	float inside_sqrt = 1.0 - x_ratio * x_ratio;
	float arch_y = 1.0 - top_h - (b - top_h) * pow(max(inside_sqrt, 0.0), 0.5 / _ArchCurve);

	if (inside_sqrt < 0.0) {
		// 超出拱形水平范围，直接返回一个极大值（视为完全在外部）
		return -abs(abs(p.x) - a)*0.5 - abs(p.y - arch_y)*0.7;
	}
	
	// 返回点到拱形轮廓线的真实垂直物理距离（带符号）
	return p.y - arch_y; 
}

// SDF for left diagonal edge (negative = right of line, inside)
float left_diagonal_sdf(vec2 uv) {
	// 将直线转换为一般式: x - _LeftSideSlope * y - _LeftSideX = 0
	// 计算分子部分（带符号的原始距离）
	float numerator = uv.x - _LeftSideSlope * uv.y - _LeftSideX;
	
	// 计算分母部分（斜率的归一化因子）
	float denominator = sqrt(1.0 + _LeftSideSlope * _LeftSideSlope);
	
	// 返回真正的垂直距离
	return numerator / denominator;  
}

// SDF for right diagonal edge (negative = left of line, inside)
float right_diagonal_sdf(vec2 uv) {
	// 将直线转换为一般式: x - _RightSideSlope * uv.y - _RightSideX = 0
	// 计算分子部分（带符号的原始距离）
	float numerator = uv.x - _RightSideSlope * uv.y - _RightSideX;
	
	// 计算分母部分（斜率的归一化因子）
	float denominator = sqrt(1.0 + _RightSideSlope * _RightSideSlope);
	
	// 返回真正的垂直距离，并取反以保持“左侧为负（内部）”的逻辑
	return -numerator / denominator;  
}

// SDF for bottom edge
float bottom_sdf(vec2 uv) {
	return 1.0 - _BottomTrim - uv.y;
}

// Smooth min: 融合两个SDF，消除拐角处的不均匀
float smooth_min(float a, float b, float k) {
	float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
	return mix(b, a, h) - k * h * (1.0 - h);
}

// Combined SDF for the shape
float shape_sdf(vec2 uv) {
	float d_arch;
	vec2 p = uv - vec2(0.5, 0.0);
	float a = _ArchWidth;
	float b = _ArchHeight;
	float top_h = _ArchTopHeight;
	
	// 计算当前 x 坐标下，拱形轮廓的理论 y 值
	float x_ratio = p.x / a;
	float inside_sqrt = 1.0 - x_ratio * x_ratio;
	float arch_y = 1.0 - top_h - (b - top_h) * pow(max(inside_sqrt, 0.0), 0.5 / _ArchCurve);

	if (inside_sqrt < 0.0) {
		// 超出拱形水平范围
		//d_arch = -abs(abs(p.x) - a)*0.1 - abs(p.y - arch_y)*1.0;
		//d_arch = - sqrt(pow(abs(p.x) - a, 2.0) + pow(abs(p.y - arch_y), 2.0));
	}
	else{
		d_arch = p.y - arch_y; 
	}
	
	float d_left;
	float numerator = uv.x - _LeftSideSlope * uv.y - _LeftSideX;
	float denominator = sqrt(1.0 + _LeftSideSlope * _LeftSideSlope);
	if (p.y < arch_y){
		d_left = (numerator / denominator)*2.0 + (arch_y - p.y)*1.0;  
	}
	else{
		d_left = numerator / denominator;  
	}
	
	
	float d_right;
	float numerator_right = uv.x - _RightSideSlope * uv.y - _RightSideX;
	float denominator_right = sqrt(1.0 + _RightSideSlope * _RightSideSlope);
	d_right = -numerator_right / denominator_right;  
	
	float d_bottom = 1.0 - _BottomTrim - uv.y;

	//使用 smooth_min 代替 min，让拐角处距离过渡平滑
	float d = smooth_min(d_arch, d_left, 0.1);
	d = smooth_min(d, d_right, 0.1);
	d = smooth_min(d, d_bottom, 0.1);
	
	//float d = smooth_min(d_right, d_left, 0.1);
	//d = smooth_min(d, d_bottom, 0.1);
	
	return d;
	//return d_arch;
	//return d_left;
}


//// Combined SDF for the shape
//float shape_sdf(vec2 uv) {
	//float d_arch = arch_sdf(uv);
	//float d_left = left_diagonal_sdf(uv);
	//float d_right = right_diagonal_sdf(uv);
	//float d_bottom = bottom_sdf(uv);
//
	 ////使用 smooth_min 代替 min，让拐角处距离过渡平滑
	//float d = smooth_min(d_arch, d_left, 0.1);
	//d = smooth_min(d, d_right, 0.1);
	//d = smooth_min(d, d_bottom, 0.1);
	//return d;
	////return d_arch;
	////return d_left;
//}


//float smooth_max(float a, float b, float k) {
    //float h = clamp(0.5 - 0.5 * (b - a) / k, 0.0, 1.0);
    //return mix(b, a, h) + k * h * (1.0 - h);
//}
//
//// 综合 SDF：将四个部分融合为一个完整的封闭图形
//float shape_sdf(vec2 uv) {
	//float d_arch = arch_sdf(uv);
	//float d_left = left_diagonal_sdf(uv);
	//float d_right = right_diagonal_sdf(uv);
	//float d_bottom = bottom_sdf(uv);
//
    //// ⚠️ 注意：这里必须用 smooth_max (平滑交集)，绝对不能用 min！
    //// k 值 (例如 0.05) 控制圆角的大小，值越大拐角越圆润
    //float d = smooth_max(d_arch, d_left, 0.05);
    //d = smooth_max(d, d_right, 0.05);
    //d = smooth_max(d, d_bottom, 0.05);
    //
	//return d;
//}

void fragment() {
	vec2 uv = UV;

	// Calculate pulse effect
	float pulse = 1.0 + _PulseAmount * sin(TIME * _PulseSpeed);

	// Calculate SDF distance from shape edge
	float dist = shape_sdf(uv);

	// Calculate glow based on distance (核心修改点)
	float glow = 0.0;

	if (is_in_region(uv)) {
		// 形状内部：最亮
		glow = 1.0;
	} 
	else {
		// inside shape: 正常的向外衰减辉光
		glow = exp(-abs(dist) * _GlowFalloff * 0.5);
		//glow = 0.0;
	}

	// Apply pulse and intensity (稍微提高一点整体强度的基准)
	glow *= _GlowIntensity * pulse * 1.5;

	// Output color with additive blend
	COLOR = vec4(_GlowColor.rgb * glow, 1.0);
}