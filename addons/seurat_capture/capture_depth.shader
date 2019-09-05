shader_type spatial;
render_mode cull_disabled, unshaded; // unshaded to get the unmodified color out into the texture

void vertex() {
  POSITION = vec4(VERTEX, 1.0); // we render a screen space quad with this shader; so no transform
}


void fragment() {
	float frag_z = texture(DEPTH_TEXTURE, SCREEN_UV).r; // fragment depth in [0, 1]; would be WINDOW_Z for seurat
	vec4 unproj = INV_PROJECTION_MATRIX * vec4(0.0, 0.0, frag_z * 2.0 - 1.0, 1.0); 
	float linear_z = -unproj.z / unproj.w; // linear depth in [0, inf]; EYE_Z for seurat
	
	//float alpha = (frag_z<1.0)?1.0:0.0; // this currently does not work to export via exr; would be usefull as depth mask
	
	if (frag_z == 1.0) linear_z = 0.0; // set to 0.0 when we are at or behind the far plane (seurat will detect this)
	
	ALBEDO.rgb = vec3(linear_z);
}
