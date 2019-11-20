shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform sampler2D seurat_texture;

void fragment() {
	vec4 tex = texture(seurat_texture, UV);
	
	//ALBEDO = pow(tex.rgb, vec3(2.2)) / (tex.a); // with approx. gamma correction
	ALBEDO = tex.rgb / (tex.a); // without gamma
	
	ALPHA = tex.a;
}
