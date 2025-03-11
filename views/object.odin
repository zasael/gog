package main

import "vendor:raylib"
import "core:math/linalg"

// Transform is a 3x3 matrix for 2D transformation, (rotation and translation)
Transform :: raylib.Matrix

Object :: struct {
	id: int,
	transform: raylib.Matrix,
	children: [dynamic]^Object,
	parent: ^Object
}

// transform_point :: proc(transform: Transform, point: raylib.Matrix

draw_object :: proc(object: ^Object, transform: raylib.Matrix) {
	if object == nil {
		return
	}

	
}
