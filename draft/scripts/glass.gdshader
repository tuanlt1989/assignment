shader_type canvas_item;
// Nền kính mờ: làm mờ phần phía sau rồi phủ màu tối.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float blur : hint_range(0.0, 6.0) = 3.0;
uniform vec4 tint : source_color = vec4(0.02, 0.04, 0.08, 0.55);

void fragment() {
	vec3 c = textureLod(screen_tex, SCREEN_UV, blur).rgb;
	COLOR = vec4(mix(c, tint.rgb, tint.a), 1.0) * vec4(1.0, 1.0, 1.0, COLOR.a);
}
