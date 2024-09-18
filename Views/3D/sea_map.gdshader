shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment(){
      COLOR = texture(TEXTURE, UV); // Read from texture again.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
