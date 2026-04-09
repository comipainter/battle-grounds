shader_type canvas_item;

uniform vec4 color_override : source_color = vec4(1.0, 0.0, 0.0, 1.0); // 你想变成的颜色

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    
    // 如果原图是黑色的 (或者非常暗)，我们就用 uniform 的颜色替换它
    // 这里假设原图黑色部分是你想要变色的部分，且原图可能有抗锯齿边缘
    if (texture_color.rgb == vec3(0.0)) {
        COLOR.rgb = color_override.rgb;
    } else {
        // 如果不是黑色，保持原样（或者你也可以让它受 modulate 影响）
        COLOR = texture_color; 
    }
}