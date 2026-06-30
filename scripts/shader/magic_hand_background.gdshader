shader_type canvas_item;

// 暴露参数：裁剪掉图片顶部的比例 (0.0 - 0.5)
uniform float crop_top : hint_range(0.0, 0.5) = 0.1;
// 暴露参数：裁剪掉图片底部的比例 (0.0 - 0.5)
uniform float crop_bottom : hint_range(0.0, 0.5) = 0.1;

void fragment() {
	// 计算有效的UV范围
	float visible_range = 1.0 - crop_top - crop_bottom;

	// 将UV坐标映射到中间可见区域
	vec2 adjusted_uv = UV;
	adjusted_uv.y = crop_top + UV.y * visible_range;

	// 采样纹理
	COLOR = texture(TEXTURE, adjusted_uv);
}
