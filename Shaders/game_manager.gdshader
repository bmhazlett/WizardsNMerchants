shader_type canvas_item;
uniform float onoff;

void fragment() {
	if (onoff == 1.0) {
		COLOR.rgb = COLOR.bbb;
	}
}