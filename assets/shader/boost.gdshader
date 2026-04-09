shader_type canvas_item;
uniform float brightness : hint_range(1.0, 10.0) = 1;
uniform float speed : hint_range(0.1, 10.0) = 0.1;

// HSV 转 RGB 辅助函数
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    float hue = fract(TIME * speed); 
    vec3 rgb = hsv2rgb(vec3(hue, 1.0, 1.0));
    
    vec3 final_color = rgb * brightness;

    COLOR = vec4(final_color, tex_color.a);
}

