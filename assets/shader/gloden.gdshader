shader_type canvas_item;

// 定义参数，方便在编辑器调整
uniform float speed : hint_range(0.1, 10.0) = 0.5; // 闪烁速度
uniform float intensity : hint_range(0.0, 5.0) = 5.0; // 金光强度
uniform vec4 gold_color : source_color = vec4(1.0, 0.84, 0.0, 1.0); // 金色

void fragment() {
    // 获取原始纹理颜色
    vec4 tex_color = texture(TEXTURE, UV);
    
    // 如果像素完全透明，直接丢弃（优化性能）
    if (tex_color.a < 0.01) {
        discard;
    }

    // 计算时间变量
    float time = TIME * speed;
    
    // 创建闪烁函数：使用 sin 和 cos 组合制造不规则的闪耀感
    // 这里的 0.5 + 0.5 * sin(...) 会在 0 到 1 之间波动
    float shine = 0.5 + 0.5 * sin(time * 10.0); 
    shine += 0.3 * sin(time * 23.0 + UV.x * 10.0); // 增加一些空间上的波纹
    
    // 限制最大值，防止过曝太严重，除非你想要纯白
    shine = clamp(shine, 0.0, 1.0);

    // 混合颜色：原始颜色 + 金色闪光
    // 使用 mix 函数，当 shine 越高，金色越重
    vec3 final_color = mix(tex_color.rgb, gold_color.rgb, shine * intensity * tex_color.a);
    
    // 如果需要强烈的“发光”感，可以简单提亮
    final_color += vec3(shine * 0.5); 

    COLOR = vec4(final_color, tex_color.a);
}